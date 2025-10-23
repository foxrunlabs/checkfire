import SwiftData
import SwiftUI

struct WithholdingFormDetailView: View {
    @Bindable var withholdingForm: WithholdingForm
    @Binding var selection: PayComponent?
    
    init(for withholdingForm: WithholdingForm, selection: Binding<PayComponent?>) {
        self.withholdingForm = withholdingForm
        self._selection = selection
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.modelContext) private var modelContext
    @Query private var withholdingForms: [WithholdingForm]
    
    private var excludedDates: [Date] {
        withholdingForms.filter({ $0.id != withholdingForm.id }).map { $0.date }
    }
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Effective Date") {
                    MonthYearPicker(
                        selection: $withholdingForm.date,
                        in: WithholdingTables.shared.years,
                        excluding: excludedDates
                    )
                }
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
        .navigationTitle($withholdingForm.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Copy", systemImage: "document.on.document") {
                    copyWithholdingForm()
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteWithholdingForm()
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                }
            }
        }
    }
    
    private func copyWithholdingForm() {
        let formDates = withholdingForms.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newWithholdingForm = WithholdingForm()
        newWithholdingForm.name = withholdingForm.name + " (copy)"
        
        // if a form exists for the current month, create a form a month past the latest date
        // contained in the current query
        if formDates.contains(currentMonth) {
            let lastDate = formDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newWithholdingForm.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        newWithholdingForm.maritalStatus = withholdingForm.maritalStatus
        newWithholdingForm.multipleJobs = withholdingForm.multipleJobs
        newWithholdingForm.childDependents = withholdingForm.childDependents
        newWithholdingForm.otherDependents = withholdingForm.otherDependents
        newWithholdingForm.otherIncome = withholdingForm.otherIncome
        newWithholdingForm.deductions = withholdingForm.deductions
        newWithholdingForm.extraWithholding = withholdingForm.extraWithholding
        
        modelContext.insert(newWithholdingForm)
        selection = .withholdingForm(newWithholdingForm)
    }
    
    private func deleteWithholdingForm() {
        modelContext.delete(withholdingForm)
        selection = nil
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

fileprivate struct CurrencyField: View {
    let title: any StringProtocol
    @Binding var value: Decimal
    
    init<S>(_ title: S, value: Binding<Decimal>) where S : StringProtocol {
        self.title = title
        self._value = value
    }

    var body: some View {
        LabeledContent {
            TextField(
                title,
                value: $value,
                format: .currency(code: "USD")
            )
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
        } label: {
            Text(title)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var withholdingForm = WithholdingForm.example

    NavigationStack {
        WithholdingFormDetailView(for: withholdingForm, selection: .constant(nil))
    }
    .modelContainer(PreviewController.container)
}
