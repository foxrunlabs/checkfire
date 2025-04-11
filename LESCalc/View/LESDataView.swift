import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var basePay: Decimal = 0.00
    @State private var specialPays: Decimal = 0.00
    @State private var allowances: Decimal = 0.00
    @State private var otherDeductions: Decimal = 0.00
    @State private var allotments: Decimal = 0.00
    
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
                        value: $basePay,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.basePay = basePay
                    }
                } label: {
                    Text("Base Pay")
                }
                
                LabeledContent {
                    TextField(
                        "Special and Incentive Pays",
                        value: $specialPays,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.specialPays = specialPays
                    }
                } label: {
                    Text("Special and Incentive Pays")
                }
                
                LabeledContent {
                    TextField(
                        "Allowances",
                        value: $allowances,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.allowances = allowances
                    }
                } label: {
                    Text("Allowances")
                }
            }
            
            Section("Deductions") {
                LabeledContent {
                    TextField(
                        "Other Deductions",
                        value: $otherDeductions,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.otherDeductions = otherDeductions
                    }
                } label: {
                    Text("Other Deductions")
                }
            }
            
            Section("Allotments") {
                LabeledContent {
                    TextField(
                        "Allotments",
                        value: $allotments,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        paycheck.lesData.allotments = allotments
                    }
                } label: {
                    Text("Allotments")
                }
            }
        }
        .onAppear {
            basePay = paycheck.lesData.basePay
            specialPays = paycheck.lesData.specialPays
            allowances = paycheck.lesData.allowances
            otherDeductions = paycheck.lesData.otherDeductions
            allotments = paycheck.lesData.allotments
        }
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    LESDataView(paycheck: paycheck)
}
