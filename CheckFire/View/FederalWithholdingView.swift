import SwiftUI

struct FederalWithholdingView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Section {
                Picker("Marital Status", selection: $paycheck.federalWithholdingData.maritalStatus) {
                    ForEach(MaritalStatus.allCases) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
                .pickerStyle(.menu)
                
                Toggle(
                    "Multiple Jobs or Spouse Works",
                    isOn: $paycheck.federalWithholdingData.multipleJobs
                )
            }
            
            Section("Claim Dependents") {
                Stepper(
                    "^[\(paycheck.federalWithholdingData.childDependents) Additional Dependents](inflect: true) Under 17",
                    value: $paycheck.federalWithholdingData.childDependents,
                    in: 0...10
                )
                
                Stepper(
                    "^[\(paycheck.federalWithholdingData.otherDependents) Other Dependents](inflect: true)",
                    value: $paycheck.federalWithholdingData.otherDependents,
                    in: 0...10
                )
            }
            
            Section("Other Adjustments") {
                LabeledContent {
                    TextField(
                        "Other Income Amount - Not From Jobs",
                        value: $paycheck.federalWithholdingData.otherIncome,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Other Income Amount - Not From Jobs")
                }
                
                LabeledContent {
                    TextField(
                        "Other Deductions",
                        value: $paycheck.federalWithholdingData.deductions,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Other Deductions")
                }
                
                LabeledContent {
                    TextField(
                        "Extra Withholding Amount Monthly",
                        value: $paycheck.federalWithholdingData.extraWithholding,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Extra Withholding Amount Monthly")
                }
            }
        }
    }
}

#Preview {
    FederalWithholdingView(paycheck: Paycheck.example)
}
