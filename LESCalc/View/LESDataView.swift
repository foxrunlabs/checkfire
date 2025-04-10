import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    private var dateRange: ClosedRange<Date> {
        let startDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.first!,
            month: 1, day: 1
        ).date!
        
        let lastDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.last!,
            month: 12,
            day: 31
        ).date!
        
        return startDate...lastDate
    }
    
    var body: some View {
        Form {
            DatePicker("Pay Date",
                selection: $paycheck.date,
                in: dateRange,
                displayedComponents: .date
            )
            
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
