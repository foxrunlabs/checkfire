import SwiftData
import SwiftUI

struct WithholdingFormDetailView: View {
    @Bindable var withholdingForm: WithholdingForm
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section {
                MonthYearPicker(
                    "Effective Date",
                    selection: $withholdingForm.date,
                    in: WithholdingTables.shared.years
                )
            }
            
            Section {
                Picker("Marital Status", selection: $withholdingForm.maritalStatus) {
                    ForEach(MaritalStatus.allCases) { status in
                        Text(String(describing: status))
                            .tag(status)
                    }
                }
                .pickerStyle(.menu)

                Toggle(
                    "Multiple Jobs or Spouse Works",
                    isOn: $withholdingForm.multipleJobs
                )
            }

            Section("Claim Dependents") {
                Stepper(
                    "^[\(withholdingForm.childDependents) Additional Dependents](inflect: true) Under 17",
                    value: $withholdingForm.childDependents,
                    in: 0...10
                )

                Stepper(
                    "^[\(withholdingForm.otherDependents) Other Dependents](inflect: true)",
                    value: $withholdingForm.otherDependents,
                    in: 0...10
                )
            }

            Section("Other Adjustments") {
                CurrencyField(
                    "Other Income Amount - Not From Jobs",
                    value: $withholdingForm.otherIncome
                )

                CurrencyField(
                    "Other Deductions",
                    value: $withholdingForm.deductions
                )

                CurrencyField(
                    "Extra Withholding Amount Monthly",
                    value: $withholdingForm.extraWithholding
                )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle($withholdingForm.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Delete Withholding Form", systemImage: "trash", role: .destructive) {
                    deleteWithholdingForm()
                    dismiss()
                }
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
                .keyboardType(.decimalPad)
            } label: {
                Text(label)
            }
        }
    }
    
    private func deleteWithholdingForm() {
        modelContext.delete(withholdingForm)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var withholdingForm = WithholdingForm.example

    NavigationStack {
        WithholdingFormDetailView(withholdingForm: withholdingForm)
    }
}
