import SwiftData
import SwiftUI

struct AddWithholdingFormSheet: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    
    @State private var name = "New Withholding Form"
    @State private var date = Calendar.current.lastDateOfMonth(from: .now)!
    @State private var template: WithholdingForm?
    
    @State private var showAlert = false
    
    private var withholdingFormExists: Bool {
        withholdingForms.contains { $0.date == date }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                MonthYearPicker(
                    "Effective Date",
                    selection: $date,
                    in: WithholdingTables.shared.years
                )
                
                Picker("Template", selection: $template) {
                    Text("None")
                        .tag(nil as WithholdingForm?)
                    
                    ForEach(withholdingForms) { withholdingForm in
                        Text(
                            withholdingForm.name + " (\(withholdingForm.date.formatted(.dateTime.month().year())))"
                        )
                        .tag(withholdingForm)
                    }
                }
                .pickerStyle(.menu)
                .disabled(withholdingForms.isEmpty)

            }
            .navigationTitle("Add Withholding Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if withholdingFormExists {
                            showAlert.toggle()
                        } else {
                            addWithholdingForm()
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Effective date already exists.")
            }
        }
    }
    
    private func addWithholdingForm() {
        let newWithholdingForm = WithholdingForm()
        newWithholdingForm.name = name
        newWithholdingForm.date = date
        
        if let template {
            newWithholdingForm.maritalStatus = template.maritalStatus
            newWithholdingForm.multipleJobs = template.multipleJobs
            newWithholdingForm.childDependents = template.childDependents
            newWithholdingForm.otherDependents = template.otherDependents
            newWithholdingForm.otherIncome = template.otherIncome
            newWithholdingForm.deductions = template.deductions
            newWithholdingForm.extraWithholding = template.extraWithholding
        }
        
        modelContext.insert(newWithholdingForm)
        selectedPayComponent = .withholdingForm(newWithholdingForm)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    @Previewable @State var showSheet = true
    
    Button("Show Sheet") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        AddWithholdingFormSheet(selectedPayComponent: $selectedPayComponent)
            .presentationDetents([.medium])
    }
    .modelContainer(PreviewController.container)
}
