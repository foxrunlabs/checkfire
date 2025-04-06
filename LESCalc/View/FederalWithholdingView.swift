import SwiftUI

struct FederalWithholdingView: View {
    @Binding var myPayData: MyPayData
    
    var body: some View {
        NavigationStack {
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
                    Stepper(
                        "^[\(myPayData.childDependents) Additional Dependents](inflect: true) Under 17",
                        value: $myPayData.childDependents,
                        in: 0...10
                    )
                    
                    Stepper(
                        "^[\(myPayData.otherDependents) Other Dependents](inflect: true)",
                        value: $myPayData.otherDependents,
                        in: 0...10
                    )
                }
                
                Section("Other Adjustments") {
                    LabeledContent {
                        TextField(
                            "Other Income Amount - Not From Jobs",
                            value: $myPayData.otherIncome,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Other Income Amount - Not From Jobs")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Other Deductions",
                            value: $myPayData.deductions,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Other Deductions")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Extra Withholding Amount Monthly",
                            value: $myPayData.extraWithholding,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Extra Withholding Amount Monthly")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Federal Withholding")
            .toolbarTitleDisplayMode(UIDevice.isiPad ? .large : .inline)
        }
    }
}

#Preview {
    @Previewable @State var myPayData = MyPayData()
    FederalWithholdingView(myPayData: $myPayData)
}
