import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    private var withholdingFormDate: String {
        paycheck.withholdingForm?.date.formatted(.dateTime.month().year()) ?? "No Data"
    }
    
    private var tspDate: String {
        paycheck.thriftSavingsPlan?.date.formatted(.dateTime.month().year()) ?? "No Data"
    }
    
    var body: some View {
        List {
            Group {
                Section {
                    LabeledCurrency("Gross Pay", value: paycheck.grossPay)
                    LabeledCurrency("Wage Period", value: paycheck.wagePeriod)
                }
                
                Section {
                    LabeledCurrency("Traditional TSP", value: paycheck.traditionalTSPContribution)
                    LabeledCurrency("Roth TSP", value: paycheck.rothTSPContribution)
                }
                
                Section {
                    LabeledCurrency("Federal Taxes", value: paycheck.federalTaxes)
                    LabeledCurrency("Social Security", value: paycheck.socialSecurity)
                    LabeledCurrency("Medicare", value: paycheck.medicare)
                }
                
                Section {
                    LabeledCurrency("Net Pay", value: paycheck.netPay)
                }
                
                Section {
                    LabeledContent("Withholding Form") {
                        Text(withholdingFormDate)
                    }
                    
                    LabeledContent("Thrift Savings Plan") {
                        Text(tspDate)
                    }
                }
            }
        }
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
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        NetPayView(paycheck: paycheck)
    }
}
