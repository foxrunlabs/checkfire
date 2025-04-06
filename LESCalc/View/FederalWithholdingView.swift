import SwiftUI

struct FederalWithholdingView: View {
    @Binding var myPayData: MyPayData
    
    var body: some View {
        Form {
            Section {
                Picker("Marital Status", selection: $myPayData.maritalStatus) {
                    ForEach(MaritalStatus.allCases) { status in
                        Text(status.description)
                            .tag(status)
                    }
                }
                
                Toggle("Multiple Jobs or Spouse Works", isOn: $myPayData.multipleJobs)
            }
            
            Section("Claim Dependents") {
                Stepper("\(myPayData.childDependents) Additional Dependents Under 17", value: $myPayData.childDependents, in: 0...10)
                
                Stepper("\(myPayData.otherDependents) Other Dependents", value: $myPayData.otherDependents, in: 0...10)
            }
            
            Section("Other Adjustments") {
                TextField(
                    "Other Income Amount - Not From Jobs",
                    value: $myPayData.otherIncome,
                    format: .currency(code: "USD")
                )
                
                TextField("Other Deductions", value: $myPayData.deductions, format: .currency(code: "USD"))
                
                TextField(
                    "Extra Withholding Amount Monthly",
                    value: $myPayData.extraWithholding,
                    format: .currency(code: "USD")
                )
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    FederalWithholdingView(myPayData: .constant(MyPayData()))
}
