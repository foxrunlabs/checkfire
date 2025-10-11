import SwiftData
import SwiftUI

struct AddTSPSheet: View {
    @Binding var selection: PayComponent?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var name = "New Thrift Savings Plan"
    @State private var date = Calendar.current.lastDateOfMonth(from: .now)!
    @State private var template: ThriftSavingsPlan?
    
    private var excludedDates: [Date] {
        thriftSavingsPlans.map { $0.date }
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
                    in: WithholdingTables.shared.years,
                    excluding: excludedDates
                )
                
                Picker("Template", selection: $template) {
                    Text("None")
                        .tag(nil as ThriftSavingsPlan?)
                    
                    ForEach(thriftSavingsPlans) { tsp in
                        Text(tsp.name + " (\(tsp.date.formatted(.dateTime.month().year())))")
                            .tag(tsp)
                    }
                }
                .pickerStyle(.menu)
                .disabled(thriftSavingsPlans.isEmpty)
            }
            .navigationTitle("Add Thrift Savings Plan")
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
                            addTSP()
                            dismiss()
                        }
                    } else {
                        Button("Add") {
                            addTSP()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func addTSP() {
        let newTSP = ThriftSavingsPlan()
        newTSP.name = name
        newTSP.date = date
        
        if let template {
            newTSP.traditionalBasicPay = template.traditionalBasicPay
            newTSP.traditionalSpecialPay = template.traditionalSpecialPay
            newTSP.traditionalIncentivePay = template.traditionalIncentivePay
            newTSP.traditionalBonusPay = template.traditionalBonusPay
            newTSP.rothBasicPay = template.rothBasicPay
            newTSP.rothSpecialPay = template.rothSpecialPay
            newTSP.rothIncentivePay = template.rothIncentivePay
            newTSP.rothBonusPay = template.rothBonusPay
        }
        
        modelContext.insert(newTSP)
        selection = .thriftSavingsPlan(newTSP)
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
        AddTSPSheet(selection: $selectedPayComponent)
            .presentationDetents([.medium])
    }
    .modelContainer(PreviewController.container)
}

