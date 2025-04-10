import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Picker("Year", selection: $paycheck.year) {
                ForEach(TaxYears.shared.years, id: \.self) { year in
                    Text(year.description)
                        .tag(year)
                }
            }
            
            Section("Entitlements") {
                LabeledContent {
                    TextField(
                        "Base Pay",
                        value: $paycheck.lesData.basePay,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Base Pay")
                }
                
                LabeledContent {
                    TextField(
                        "Special and Incentive Pays",
                        value: $paycheck.lesData.specialPays,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Special and Incentive Pays")
                }
                
                LabeledContent {
                    TextField(
                        "Allowances",
                        value: $paycheck.lesData.allowances,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Allowances")
                }
            }
            
            Section("Deductions") {
                LabeledContent {
                    TextField(
                        "Other Deductions",
                        value: $paycheck.lesData.otherDeductions,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Other Deductions")
                }
            }
            
            Section("Allotments") {
                LabeledContent {
                    TextField(
                        "Allotments",
                        value: $paycheck.lesData.allotments,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Allotments")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    LESDataView(paycheck: paycheck)
}
