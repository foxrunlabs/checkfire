import SwiftData
import SwiftUI

struct AddPaycheckSheet: View {
    @Binding var selection: PayComponent?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    @State private var name = "New Paycheck"
    @State private var date = Calendar.current.lastDateOfMonth(from: .now)!
    @State private var template: Paycheck?
    
    private var excludedDates: [Date] {
        paychecks.map { $0.date }
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
                    in: WithholdingTables.shared.years,
                    excluding: excludedDates
                )
                
                Picker("Template", selection: $template) {
                    Text("None")
                        .tag(nil as Paycheck?)
                    
                    ForEach(paychecks) { paycheck in
                        Text(
                            paycheck.name + " (\(paycheck.date.formatted(.dateTime.month().year())))"
                        )
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
                    if #available(iOS 26, *) {
                        Button("Cancel", systemImage: "xmark") {
                            dismiss()
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button("Add", systemImage: "checkmark") {
                            addPaycheck()
                            dismiss()
                        }
                    } else {
                        Button("Add") {
                            addPaycheck()
                            dismiss()
                        }
                    }
                }
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
            newPaycheck.basicPay = BasicPayTables.shared.basicPay(
                for: Calendar.current.component(.year, from: date),
                as: template.payGrade,
                with: template.yearsOfService
            ) ?? template.basicPay
            newPaycheck.bas = BASTables.shared.bas(
                for: Calendar.current.component(.year, from: date),
                as: template.payGrade
            ) ?? template.bas
            newPaycheck.bah = template.bah
            
            newPaycheck.lesItems = template.lesItems?.map {
                LESItem(name: $0.name, amount: $0.amount, type: $0.type)
            }
        }
        
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
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
        AddPaycheckSheet(selection: $selectedPayComponent)
            .presentationDetents([.medium])
    }
    .modelContainer(PreviewController.container)
}
