import SwiftUI

struct FederalWithholdingView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Section {
                Picker("Marital Status", selection: $paycheck.myPayData.maritalStatus) {
                    ForEach(MaritalStatus.allCases) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
                .pickerStyle(.menu)
                
                Toggle("Multiple Jobs or Spouse Works", isOn: $paycheck.myPayData.multipleJobs)
            }
            
            Section("Claim Dependents") {
                Stepper(
                    "^[\(paycheck.myPayData.childDependents) Additional Dependents](inflect: true) Under 17",
                    value: $paycheck.myPayData.childDependents,
                    in: 0...10
                )
                
                Stepper(
                    "^[\(paycheck.myPayData.otherDependents) Other Dependents](inflect: true)",
                    value: $paycheck.myPayData.otherDependents,
                    in: 0...10
                )
            }
            
            Section("Other Adjustments") {
                LabeledContent {
                    TextField(
                        "Other Income Amount - Not From Jobs",
                        value: $paycheck.myPayData.otherIncome,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Other Income Amount - Not From Jobs")
                }
                
                LabeledContent {
                    TextField(
                        "Other Deductions",
                        value: $paycheck.myPayData.deductions,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                    Text("Other Deductions")
                }
                
                LabeledContent {
                    TextField(
                        "Extra Withholding Amount Monthly",
                        value: $paycheck.myPayData.extraWithholding,
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
    @Previewable @State var paycheck = Paycheck.example
    FederalWithholdingView(paycheck: paycheck)
}
