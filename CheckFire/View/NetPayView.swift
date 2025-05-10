import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        List {
            Group {
                Section {
                    LabeledCurrency("Gross Pay", value: paycheck.lesData.grossPay)
                    LabeledCurrency("Wage Period", value: paycheck.wagePeriod)
                }
                
                Section {
                    LabeledCurrency("Traditional TSP", value: paycheck.traditionalTspContribution)
                    LabeledCurrency("Roth TSP", value: paycheck.rothTspContribution)
                }
                
                Section {
                    LabeledCurrency("Federal Taxes", value: paycheck.federalTaxes)
                    LabeledCurrency("Social Security", value: paycheck.socialSecurity)
                    LabeledCurrency("Medicare", value: paycheck.medicare)
                }
                
                Section {
                    LabeledCurrency("Net Pay", value: paycheck.netPay)
                }
            }
            .checkFireListRowStyle(themeManager: themeManager)
        }
        .checkFireListBackground(themeManager: themeManager)
    }
    
    private struct LabeledCurrency: View {
        private let label: String
        private let value: Decimal
        
        init(_ label: String, value: Decimal) {
            self.label = label
            self.value = value
        }
        
        var body: some View {
            LabeledContent {
                Text(value.formatted(.currency(code: "USD")))
            } label: {
                Text(label)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NetPayView(paycheck: Paycheck.example)
        .environment(ThemeManager(theme: .system))
}
