import SwiftData
import SwiftUI

struct WithholdingFormDetailView: View {
    @Bindable private var withholdingForm: WithholdingForm
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]

    init(for withholdingForm: WithholdingForm) {
        self.withholdingForm = withholdingForm
    }
    
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
            
            if let paychecks = withholdingForm.paychecks {
                if !paychecks.isEmpty {
                    Section("Paychecks") {
                        ForEach(paychecks) { paycheck in
                            LabeledContent(paycheck.name) {
                                Text(paycheck.date, format: .dateTime.month().year())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle($withholdingForm.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Delete Withholding Form", systemImage: "trash", role: .destructive) {
                    deleteWithholdingForm()
                    dismiss()
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                // dismiss the keyboard
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
        }
        .onChange(of: withholdingForm.date) {
            updatePaychecks()
        }
    }
    
    private func deleteWithholdingForm() {
        modelContext.delete(withholdingForm)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // re-associate paychecks to remaining withholding forms
        paychecks.forEach { paycheck in
            paycheck.withholdingForm = withholdingForms.last { withholdingForm in
                withholdingForm.date <= paycheck.date
            }
        }
    }

    private func updatePaychecks() {
        paychecks.forEach { paycheck in
            paycheck.withholdingForm = withholdingForms.last { $0.date <= paycheck.date }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var withholdingForm = WithholdingForm.example

    NavigationStack {
        WithholdingFormDetailView(for: withholdingForm)
    }
    .modelContainer(PreviewController.container)
}
