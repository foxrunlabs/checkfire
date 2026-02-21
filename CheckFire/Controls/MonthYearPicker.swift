import Foundation
import SwiftUI

struct MonthYearPicker<Label: View>: View {
    typealias Year = Int
    typealias Month = Int
    
    // MARK: - Properties
    @Binding var selection: Date
    let yearRange: ClosedRange<Year>
    let label: () -> Label
    
    @State private var showPickerPopover = false
    
    // MARK: - Initializer
    init(selection: Binding<Date>, in yearRange: ClosedRange<Year>, label: @escaping () -> Label) {
        self._selection = selection
        self.yearRange = yearRange
        self.label = label
    }
    
    // MARK: - Body
    var body: some View {
        Button {
            showPickerPopover.toggle()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPickerPopover, arrowEdge: .top) {
            PickerPopover(selection: $selection, in: yearRange)
                .presentationCompactAdaptation(.popover)
        }
    }
}


// MARK: - Picker Popover
extension MonthYearPicker {
    private struct PickerPopover: View {
        @Binding var selection: Date
        let yearRange: ClosedRange<Year>
        
        @State private var pickerYear: Year
        
        // MARK: - Initializer
        init(selection: Binding<Date>, in yearRange: ClosedRange<Year>) {
            self._selection = selection
            self.yearRange = yearRange
            
            let year = Calendar.current.component(.year, from: selection.wrappedValue)
            self._pickerYear = State(initialValue: year)
        }
        
        // MARK: - Body
        var body: some View {
            VStack {
                YearStepper(year: $pickerYear, in: yearRange)
                MonthPicker(selection: $selection, year: pickerYear)
            }
            .padding()
        }
    }
}


// MARK: - Year Stepper
extension MonthYearPicker {
    private struct YearStepper: View {
        @Binding var year: Year
        let yearRange: ClosedRange<Year>
        
        // MARK: - Initializer
        init(year: Binding<Year>, in yearRange: ClosedRange<Year>) {
            self._year = year
            self.yearRange = yearRange
        }
        
        // MARK: - Body
        var body: some View {
            HStack {
                Button {
                    year = max(year - 1, yearRange.lowerBound)
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .disabled(year == yearRange.lowerBound)
                
                Text(String(describing: year))
                    .foregroundStyle(.primary)
                    .bold()
                
                Button {
                    year = min(year + 1, yearRange.upperBound)
                } label: {
                    Image(systemName: "chevron.right")
                        .bold()
                }
                .disabled(year == yearRange.upperBound)
            }
        }
    }
}


// MARK: - Month Picker
extension MonthYearPicker {
    private struct MonthPicker: View {
        @Binding var selection: Date
        let year: Year
        
        private let columns = Array(repeating: GridItem(), count: 3)
        private let symbols = Calendar.current.shortMonthSymbols
        
        // MARK: - Initializer
        init(selection: Binding<Date>, year: Year) {
            self._selection = selection
            self.year = year
        }
        
        // MARK: - Body
        var body: some View {
            // Build a 3 x 4 matrix of MonthButtons
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<12) { month in
                    Button(symbols[month]) {
                        updateSelection(month: month + 1)
                    }
                    .buttonStyle(MonthButtonStyle(isSelected: isCurrentDate(month: month + 1)))
                }
            }
        }
        
        // MARK: - Methods
        private func isCurrentDate(month: Month) -> Bool {
            let selectionComponents = Calendar.current.dateComponents([.year, .month], from: selection)
            return (month == selectionComponents.month) && (year == selectionComponents.year)
        }
        
        private func updateSelection(month: Month) {
            let calendar = Calendar.current
            
            guard
                let firstOfMonth = calendar.date(from: .init(year: year, month: month, day: 1)),
                let lastOfMonth = calendar.lastDateOfMonth(from: firstOfMonth)
            else {
                return
            }
            
            selection = lastOfMonth
        }
    }
}


// MARK: - Month Button Style
extension MonthYearPicker {
    private struct MonthButtonStyle: ButtonStyle {
        let isSelected: Bool
        
        @Environment(\.isEnabled) private var isEnabled
        
        // MARK: - Computed Properties
        private var foregroundColor: Color {
            if isEnabled {
                isSelected ? .accentColor : .primary
            } else {
                .secondary
            }
        }
        
        // MARK: - ButtonStyle
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
    
    let years = WithholdingTableRepository(from: "withholding_tables.json").years
    
    Form {
        LabeledContent("Date") {
            MonthYearPicker(selection: $date, in: years) {
                Text(date.formatted(.dateTime.month().year()))
                    .font(.title2)
                    .bold()
            }
        }
    }
}
