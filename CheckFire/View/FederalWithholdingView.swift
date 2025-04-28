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
                CurrencyField(
                    "Other Income Amount - Not From Jobs",
                    value: $paycheck.federalWithholdingData.otherIncome
                )
                
                CurrencyField(
                    "Other Deductions",
                    value: $paycheck.federalWithholdingData.deductions
                )
                
                CurrencyField(
                    "Extra Withholding Amount Monthly",
                    value: $paycheck.federalWithholdingData.extraWithholding
                )
            }
        }
    }
    
    private struct CurrencyField: View {
        private let label: String
        @Binding private var value: Decimal
        
        init(_ label: String, value: Binding<Decimal>) {
            self.label = label
            self._value = value
        }
        
        var body: some View {
            LabeledContent {
                TextField(
                    label,
                    value: $value,
                    format: .currency(code: "USD")
                )
                .multilineTextAlignment(.trailing)
            } label: {
                Text(label)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FederalWithholdingView(paycheck: Paycheck.example)
}
