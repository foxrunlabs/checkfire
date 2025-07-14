import SwiftUI

struct MonthYearPicker: View {
    init<S>(
        _ title: S,
        selection: Binding<Date>,
        in bounds: ClosedRange<Int>,
        excluding: [Date]? = nil
    ) where S : StringProtocol {
        self.title = title
        self._selection = selection
        self.years = bounds
        self.excludedDates = excluding
    }
    
    private let title: any StringProtocol
    @Binding private var selection: Date
    private let years: ClosedRange<Int>
    private let excludedDates: [Date]?
    
    @State private var showPickerPopover = false
    
    var body: some View {
        LabeledContent(title) {
            Button {
                showPickerPopover.toggle()
            } label: {
                HStack(spacing: 5) {
                    Text(selection.formatted(.dateTime.month().year()))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                }
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $showPickerPopover, arrowEdge: .top) {
                PickerPopover(selection: $selection, in: years, excluding: excludedDates)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
    
    private struct PickerPopover: View {
        init(selection: Binding<Date>, in bounds: ClosedRange<Int>, excluding: [Date]? = nil) {
            self._selection = selection
            self.years = bounds
            self.excludedDates = excluding
            
            let year = Calendar.current.component(.year, from: selection.wrappedValue)
            self._pickerYear = State(initialValue: year)
        }
        
        @Binding private var selection: Date
        private let years: ClosedRange<Int>
        private let excludedDates: [Date]?
        @State private var pickerYear: Int
        
        var body: some View {
            VStack {
                YearStepper(String(describing: pickerYear), value: $pickerYear, in: years)
                MonthPicker(selection: $selection, year: pickerYear, excluding: excludedDates)
            }
            .padding()
        }
    }
    
    private struct YearStepper: View {
        init<S>(
            _ title: S,
            value: Binding<Int>,
            in bounds: ClosedRange<Int>
        ) where S : StringProtocol {
            self.title = title
            self._year = value
            self.years = bounds
        }
        
        private let title: any StringProtocol
        @Binding private var year: Int
        private let years: ClosedRange<Int>
        
        var body: some View {
            HStack {
                Button {
                    year = max(year - 1, years.lowerBound)
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .disabled(year == years.lowerBound)
                
                Text(title)
                    .foregroundStyle(.primary)
                    .bold()
                
                Button {
                    year = min(year + 1, years.upperBound)
                } label: {
                    Image(systemName: "chevron.right")
                        .bold()
                }
                .disabled(year == years.upperBound)
            }
        }
    }
    
    private struct MonthPicker: View {
        init(selection: Binding<Date>, year: Int, excluding: [Date]? = nil) {
            self._selection = selection
            self.year = year
            self.excludedDates = excluding
            
            self.currentDate = selection.wrappedValue
        }
        
        @Binding private var selection: Date
        private let year: Int
        private let excludedDates: [Date]?
        
        private let currentDate: Date
        
        var body: some View {
            // Build a 3 x 4 matrix of MonthButtons
            Grid {
                ForEach(0..<4) { row in
                    GridRow {
                        Button(Calendar.current.shortMonthSymbols[3 * row]) {
                            updateSelection(month: 3 * row + 1)
                        }
                        .buttonStyle(
                            MonthButtonStyle(isSelected: isCurrentDate(month: 3 * row + 1))
                        )
                        .disabled(isExcludedDate(month: 3 * row + 1))
                        
                        Button(Calendar.current.shortMonthSymbols[3 * row + 1]) {
                            updateSelection(month: 3 * row + 2)
                        }
                        .buttonStyle(
                            MonthButtonStyle(isSelected: isCurrentDate(month: 3 * row + 2))
                        )
                        .disabled(isExcludedDate(month: 3 * row + 2))
                        
                        Button(Calendar.current.shortMonthSymbols[3 * row + 2]) {
                            updateSelection(month: 3 * row + 3)
                        }
                        .buttonStyle(
                            MonthButtonStyle(isSelected: isCurrentDate(month: 3 * row + 3))
                        )
                        .disabled(isExcludedDate(month: 3 * row + 3))
                    }
                }
            }
        }
        
        private func isCurrentDate(month: Int) -> Bool {
            let components = Calendar.current.dateComponents([.year, .month], from: currentDate)
            return (month == components.month!) && (year == components.year!)
        }
        
        private func isExcludedDate(month: Int) -> Bool {
            guard let excludedDates else { return false }
            
            var date = DateComponents(calendar: .current, year: year, month: month, day: 1).date!
            date = Calendar.current.lastDateOfMonth(from: date)!
            
            return excludedDates.contains(date)
        }
        
        private func updateSelection(month: Int) {
            let newDate = DateComponents(
                calendar: .current,
                year: year,
                month: month,
                day: 1
            ).date ?? selection
            selection = Calendar.current.lastDateOfMonth(from: newDate) ?? selection
        }
    }
    
    private struct MonthButtonStyle: ButtonStyle {
        let isSelected: Bool
        
        @Environment(\.isEnabled) private var isEnabled
        
        private var foregroundColor: Color {
            if isEnabled {
                isSelected ? .accentColor : .primary
            } else {
                .secondary
            }
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 50, height: 35)
                .bold(isSelected)
                .foregroundStyle(foregroundColor)
                .background(isSelected ? Color.accentColor.opacity(0.25) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var date = DateComponents(
        calendar: .current,
        year: 2025,
        month: 2,
        day: 28
    ).date!
    
    @Previewable @State var excludedDates = [
        DateComponents(calendar: .current, year: 2025, month: 1, day: 31).date!,
        DateComponents(calendar: .current, year: 2024, month: 12, day: 31).date!
    ]
    
    Form {
        MonthYearPicker(
            "Pay Date",
            selection: $date,
            in: WithholdingTables.shared.years,
            excluding: excludedDates
        )
    }
}
