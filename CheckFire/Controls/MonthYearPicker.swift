import SwiftUI

struct MonthYearPicker: View {
    private let title: String
    @Binding private var selection: Date
    private let yearRange: ClosedRange<Int>
    
    @State private var showPicker = false
    
    init(_ title: String, selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
        self.title = title
        self._selection = selection
        self.yearRange = yearRange
    }
    
    var body: some View {
        LabeledContent {
            Button(selection.formatted(.dateTime.month().year()))
            {
                showPicker.toggle()
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $showPicker, arrowEdge: .top) {
                PickerView(selection: $selection, in: yearRange)
                    .presentationCompactAdaptation(.popover)
            }
        } label: {
            Text(title)
        }
    }
    
    private struct PickerView: View {
        @Binding private var selection: Date
        private let yearRange: ClosedRange<Int>
        
        init(selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
            self._selection = selection
            self.yearRange = yearRange
        }
        
        var body: some View {
            VStack {
                YearStepper(selection: $selection, in: yearRange)
                
                // Build a 3 x 4 matrix of MonthPickers
                Grid {
                    ForEach(0..<4) { row in
                        GridRow {
                            MonthPicker(3 * row + 1, selection: $selection)
                            MonthPicker(3 * row + 2, selection: $selection)
                            MonthPicker(3 * row + 3, selection: $selection)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private struct YearStepper: View {
        @Binding private var selection: Date
        private let yearRange: ClosedRange<Int>
        
        init(selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
            self._selection = selection
            self.yearRange = yearRange
        }
        
        private var selectionYear: Int { Calendar.current.component(.year, from: selection) }
        
        var body: some View {
            HStack {
                Button {
                    decrement()
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .disabled(selectionYear == yearRange.lowerBound)
                
                Text(selection.formatted(.dateTime.year()))
                    .foregroundStyle(.primary)
                    .bold()
                
                Button {
                    increment()
                } label: {
                    Image(systemName: "chevron.right")
                        .bold()
                }
                .disabled(selectionYear == yearRange.upperBound)
            }
        }
        
        private func decrement() {
            let year = Calendar.current.component(.year, from: selection)
            
            if year > yearRange.lowerBound {
                selection = Calendar.current.date(byAdding: .year, value: -1, to: selection) ?? selection
                selection = Calendar.current.lastDateOfMonth(from: selection) ?? selection
            }
        }
        
        private func increment() {
            let year = Calendar.current.component(.year, from: selection)
            
            if year < yearRange.upperBound {
                selection = Calendar.current.date(byAdding: .year, value: 1, to: selection) ?? selection
                selection = Calendar.current.lastDateOfMonth(from: selection) ?? selection
            }
        }
    }

    private struct MonthPicker: View {
        private let month: Int
        @Binding private var selection: Date
        
        private let months = Calendar.current.monthSymbols.map { $0.prefix(3) }
        
        init(_ month: Int, selection: Binding<Date>) {
            self.month = month
            self._selection = selection
        }
        
        private var selectionMonth: Int { Calendar.current.component(.month, from: selection) }
        
        var body: some View {
            Text(months[month - 1])
                .frame(width: 50, height: 35)
                .bold(selectionMonth == month)
                .foregroundStyle(selectionMonth == month ? Color.accentColor : .primary)
                .background(selectionMonth == month ? Color.accentColor.opacity(0.25) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    setMonth()
                }
        }
        
        private func setMonth() {
            var components = Calendar.current.dateComponents(
                [.calendar, .year, .month],
                from: selection
            )
            components.month = month
            selection = components.date ?? selection
            selection = Calendar.current.lastDateOfMonth(from: selection) ?? selection
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
    
    Form {
        MonthYearPicker("Pay Date", selection: $date, in: WithholdingTables.shared.years)
    }
}
