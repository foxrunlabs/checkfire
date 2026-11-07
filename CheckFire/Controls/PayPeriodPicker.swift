import Foundation
import SwiftUI

struct PayPeriodPicker<Label: View>: View {
    @Binding var selection: PayPeriod
    let yearRange: ClosedRange<Int>
    let label: () -> Label
    
    @State private var currentPayPeriod: PayPeriod
    @State private var showPickerPopover = false
    
    // MARK: - Initializer
    
    init(
        selection: Binding<PayPeriod>,
        in yearRange: ClosedRange<Int>,
        label: @escaping () -> Label
    ) {
        self._selection = selection
        self.yearRange = yearRange
        self.label = label
        self.currentPayPeriod = selection.wrappedValue
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
            VStack {
                YearStepper(selection: $currentPayPeriod, yearRange: yearRange)
                MonthPicker(selection: $selection, currentPayPeriod: currentPayPeriod)
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }
}


// MARK: - Year Stepper

extension PayPeriodPicker {
    private struct YearStepper: View {
        @Binding var selection: PayPeriod
        let yearRange: ClosedRange<Int>
        
        // MARK: - Body
        var body: some View {
            HStack {
                Button {
                    selection.year = max(selection.year - 1, yearRange.lowerBound)
                } label: {
                    Image(systemName: "chevron.left")
                        .bold()
                }
                .disabled(selection.year == yearRange.lowerBound)
                
                Text(selection.year, format: .number.grouping(.never))
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


// MARK: - Month Picker

extension PayPeriodPicker {
    private struct MonthPicker: View {
        @Binding var selection: PayPeriod
        let currentPayPeriod: PayPeriod
        
        private let columns = Array(repeating: GridItem(), count: 3)
        
        // MARK: - Body
        var body: some View {
            // Build a 3 x 4 matrix of MonthButtons
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Month.allCases) { month in
                    Button(month.shortSymbol) {
                        selection.month = month
                        selection.year = currentPayPeriod.year
                    }
                    .buttonStyle(MonthButtonStyle(isSelected: isCurrentPayPeriod(month: month)))
                }
            }
        }
        
        // MARK: - Method
        
        private func isCurrentPayPeriod(month: Month) -> Bool {
            selection == PayPeriod(year: currentPayPeriod.year, month: month)
        }
    }
}


// MARK: - Month Button Style

extension PayPeriodPicker {
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
    @Previewable @State var payPeriod = PayPeriod(year: 2025, month: .february)
    let years = PaySystem(from: "withholding_tables.json").taxYears
    
    Form {
        LabeledContent("Date") {
            PayPeriodPicker(selection: $payPeriod, in: years) {
                Text(payPeriod.formatted())
                    .font(.title2)
                    .bold()
            }
        }
    }
}
