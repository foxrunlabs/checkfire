import SwiftData
import SwiftUI

struct AddPaycheckSheet: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var name = "New Paycheck"
    @State private var date = Calendar.current.lastDateOfMonth(from: .now)!
    @State private var template: Paycheck?
    
    @State private var showAlert = false
    
    private var paycheckExists: Bool {
        paychecks.contains { $0.date == date }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                MonthYearPicker(
                    "Pay Date",
                    selection: $date,
                    in: WithholdingTables.shared.years
                )
                
                Picker("Template", selection: $template) {
                    Text("None")
                        .tag(nil as Paycheck?)
                    
                    ForEach(paychecks) { paycheck in
                        Text(paycheck.name)
                            .tag(paycheck)
                    }
                }
                .pickerStyle(.menu)
                .disabled(paychecks.isEmpty)
            }
            .navigationTitle("Add Paycheck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if paycheckExists {
                            showAlert.toggle()
                        } else {
                            addPaycheck()
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Pay date already exists.")
            }
        }
    }
    
    private func addPaycheck() {
        let newPaycheck = Paycheck()
        newPaycheck.name = name
        newPaycheck.date = date
        
        if let template {
            newPaycheck.payGrade = template.payGrade
            newPaycheck.yearsOfService = template.yearsOfService
            newPaycheck.basePay = template.basePay
            
            newPaycheck.lesItems = template.lesItems?.map {
                LESItem(name: $0.name, amount: $0.amount, itemType: $0.itemType)
            }
        }
        
        newPaycheck.withholdingForm = withholdingForms.last { $0.date <= newPaycheck.date }
        newPaycheck.thriftSavingsPlan = thriftSavingsPlans.last { $0.date <= newPaycheck.date }
        
        modelContext.insert(newPaycheck)
        selectedPayComponent = .paycheck(newPaycheck)
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
        AddPaycheckSheet(selectedPayComponent: $selectedPayComponent)
            .presentationDetents([.medium])
    }
    .modelContainer(PreviewController.container)
}
