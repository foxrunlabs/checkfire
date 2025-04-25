import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    var body: some View {
        List {
            Section {
                LabeledContent {
                    Text(paycheck.lesData.grossPay.formatted(.currency(code: "USD")))
                } label: {
                    Text("Gross Pay")
                }
                
                LabeledContent {
                    Text(paycheck.wagePeriod.formatted(.currency(code: "USD")))
                } label: {
                    Text("Wage Period")
                }
            }
            
            Section {
                LabeledContent {
                    Text(paycheck.traditionalTspContribution.formatted(.currency(code: "USD")))
                } label: {
                    Text("Traditional TSP")
                }
                
                LabeledContent {
                    Text(paycheck.rothTspContribution.formatted(.currency(code: "USD")))
                } label: {
                    Text("Roth TSP")
                }
            }
            
            Section {
                LabeledContent {
                    Text(paycheck.federalTaxes.formatted(.currency(code: "USD")))
                } label: {
                    Text("Federal Taxes")
                }
                
                LabeledContent {
                    Text(paycheck.socialSecurity.formatted(.currency(code: "USD")))
                } label: {
                    Text("Social Security")
                }
                
                LabeledContent {
                    Text(paycheck.medicare.formatted(.currency(code: "USD")))
                } label: {
                    Text("Medicare")
                }
            }
            
            Section {
                LabeledContent {
                    Text(paycheck.netPay.formatted(.currency(code: "USD")))
                } label: {
                    Text("Net Pay")
                }
            }
        }
    }
}

#Preview {
    NetPayView(paycheck: Paycheck.example)
}
