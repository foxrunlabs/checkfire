import SwiftData
import SwiftUI

struct TSPDetailView: View {
    init(for tsp: ThriftSavingsPlan) {
        self.tsp = tsp
    }
    
    @Bindable private var tsp: ThriftSavingsPlan
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    private var excludedDates: [Date] {
        thriftSavingsPlans.filter({ $0.id != tsp.id }).map { $0.date }
    }
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Effective Date") {
                    MonthYearPicker(
                        selection: $tsp.date,
                        in: WithholdingTables.shared.years,
                        excluding: excludedDates
                    )
                }
            }
            
            Section("Traditional TSP") {
                TSPStepper("Basic Pay", value: $tsp.traditionalBasicPay, max: 1 - tsp.rothBasicPay)
                
                TSPStepper(
                    "Special Pay",
                    value: $tsp.traditionalSpecialPay,
                    max: 1 - tsp.rothSpecialPay
                )
                .disabled(tsp.traditionalBasicPay.isZero)
                
                TSPStepper(
                    "Incentive Pay",
                    value: $tsp.traditionalIncentivePay,
                    max: 1 - tsp.rothIncentivePay
                )
                .disabled(tsp.traditionalBasicPay.isZero)
                
                TSPStepper(
                    "Bonus Pay",
                    value: $tsp.traditionalBonusPay,
                    max: 1 - tsp.rothBonusPay
                )
                .disabled(tsp.traditionalBasicPay.isZero)
            }

            Section("Roth TSP") {
                TSPStepper("Basic Pay", value: $tsp.rothBasicPay, max: 1 - tsp.traditionalBasicPay)

                TSPStepper(
                    "Special Pay",
                    value: $tsp.rothSpecialPay,
                    max: 1 - tsp.traditionalSpecialPay
                )
                .disabled(tsp.rothBasicPay.isZero)
                
                TSPStepper(
                    "Incentive Pay",
                    value: $tsp.rothIncentivePay,
                    max: 1 - tsp.traditionalIncentivePay
                )
                .disabled(tsp.rothBasicPay.isZero)

                TSPStepper(
                    "Bonus Pay",
                    value: $tsp.rothBonusPay,
                    max: 1 - tsp.traditionalBonusPay
                )
                .disabled(tsp.rothBasicPay.isZero)

            }
        }
        .navigationTitle($tsp.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tsp.traditionalBasicPay) {
            validateTraditional()
        }
        .onChange(of: tsp.rothBasicPay) {
            validateRoth()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Copy", systemImage: "document.on.document") {
                    copyTSP()
                    dismiss()
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteTSP()
                    dismiss()
                }
            }
        }
    }
    
    private func copyTSP() {
        let tspDates = thriftSavingsPlans.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newTSP = ThriftSavingsPlan()
        newTSP.name = tsp.name + " (copy)"
        
        // if a plan exists for the current month, create a plan a month past the latest date
        // contained in the current query
        if tspDates.contains(currentMonth) {
            let lastDate = tspDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newTSP.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        newTSP.traditionalBasicPay = tsp.traditionalBasicPay
        newTSP.traditionalSpecialPay = tsp.traditionalSpecialPay
        newTSP.traditionalIncentivePay = tsp.traditionalIncentivePay
        newTSP.traditionalBonusPay = tsp.traditionalBonusPay
        newTSP.rothBasicPay = tsp.rothBasicPay
        newTSP.rothSpecialPay = tsp.rothSpecialPay
        newTSP.rothIncentivePay = tsp.rothIncentivePay
        newTSP.rothBonusPay = tsp.rothBonusPay
        
        modelContext.insert(newTSP)
    }
    
    private func deleteTSP() {
        modelContext.delete(tsp)
    }
    
    private func validateTraditional() {
        if tsp.traditionalBasicPay.isZero {
            tsp.traditionalSpecialPay = 0.00
            tsp.traditionalIncentivePay = 0.00
            tsp.traditionalBonusPay = 0.00
        }
    }
    
    private func validateRoth() {
        if tsp.rothBasicPay.isZero {
            tsp.rothSpecialPay = 0.00
            tsp.rothIncentivePay = 0.00
            tsp.rothBonusPay = 0.00
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tsp = ThriftSavingsPlan.example
    
    NavigationStack {
        TSPDetailView(for: tsp)
    }
    .modelContainer(PreviewController.container)
}
