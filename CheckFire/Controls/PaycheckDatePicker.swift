import SwiftUI

struct PaycheckDatePicker: View {
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
            Button(selection.formatted(.dateTime.month().year())) { showPicker.toggle() }
                .buttonStyle(.borderless)
                .popover(isPresented: $showPicker, arrowEdge: .top) {
                    PickerView(selection: $selection, in: yearRange)
                        .presentationCompactAdaptation(.popover)
                }
        } label: {
            Text(title)
        }
    }
}

extension PaycheckDatePicker {
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
}

extension PaycheckDatePicker {
    private struct YearStepper: View {
        @Binding private var selection: Date
        private let yearRange: ClosedRange<Int>
        
        init(selection: Binding<Date>, in yearRange: ClosedRange<Int>) {
            self._selection = selection
            self.yearRange = yearRange
        }
        
        var body: some View {
            HStack {
                Button {
                    selection.year = max(yearRange.lowerBound, selection.year - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .disabled(selection.year == yearRange.lowerBound)
                
                Text(selection.formatted(.dateTime.year()))
                    .foregroundStyle(.primary)
                    .bold()
                
                Button {
                    selection.year = min(selection.year + 1, yearRange.upperBound)
                } label: {
                    Image(systemName: "chevron.right")
                        .bold()
                }
                .disabled(selection.year == yearRange.upperBound)
            }
        }
    }
}

extension PaycheckDatePicker {
    private struct MonthPicker: View {
        private let month: Int
        @Binding private var selection: Date
        
        private let months = Calendar.current.monthSymbols.map { $0.prefix(3) }
        
        init(_ month: Int, selection: Binding<Date>) {
            self.month = month
            self._selection = selection
        }
        
        var body: some View {
            Text(months[month - 1])
                .frame(width: 50, height: 35)
                .bold(selection.month == month)
                .foregroundStyle(selection.month == month ? Color.accentColor : .primary)
                .background(selection.month == month ? Color.accentColor.opacity(0.25) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    selection.month = month
                }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var date: Date = .now
    
    Form {
        PaycheckDatePicker(
            "Pay Date",
            selection: $date,
            in: WithholdingTables.shared.years.first!...WithholdingTables.shared.years.last!
        )
    }
}
