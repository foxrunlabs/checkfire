import SwiftData
import SwiftUI

struct TSPDetailView: View {
    @Bindable private var tsp: ThriftSavingsPlan
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    init(for tsp: ThriftSavingsPlan) {
        self.tsp = tsp
    }
    
    var body: some View {
        Form {
            Section {
                MonthYearPicker(
                    "Effective Date",
                    selection: $tsp.date,
                    in: WithholdingTables.shared.years
                )
            }
            
            Section("Traditional TSP") {
                TSPStepper("Base Pay", value: $tsp.traditionalBasePay, max: 1 - tsp.rothBasePay)
                
                TSPStepper(
                    "Special Pay",
                    value: $tsp.traditionalSpecialPay,
                    max: 1 - tsp.rothSpecialPay
                )
                .disabled(tsp.traditionalBasePay.isZero)
                
                TSPStepper(
                    "Incentive Pay",
                    value: $tsp.traditionalIncentivePay,
                    max: 1 - tsp.rothIncentivePay
                )
                .disabled(tsp.traditionalBasePay.isZero)
                
                TSPStepper(
                    "Bonus Pay",
                    value: $tsp.traditionalBonusPay,
                    max: 1 - tsp.rothBonusPay
                )
                .disabled(tsp.traditionalBasePay.isZero)
            }

            Section("Roth TSP") {
                TSPStepper("Base Pay", value: $tsp.rothBasePay, max: 1 - tsp.traditionalBasePay)

                TSPStepper(
                    "Special Pay",
                    value: $tsp.rothSpecialPay,
                    max: 1 - tsp.traditionalSpecialPay
                )
                .disabled(tsp.rothBasePay.isZero)
                
                TSPStepper(
                    "Incentive Pay",
                    value: $tsp.rothIncentivePay,
                    max: 1 - tsp.traditionalIncentivePay
                )
                .disabled(tsp.rothBasePay.isZero)

                TSPStepper(
                    "Bonus Pay",
                    value: $tsp.rothBonusPay,
                    max: 1 - tsp.traditionalBonusPay
                )
                .disabled(tsp.rothBasePay.isZero)

            }
            
            Section {
                Button("Reset") {
                    resetTSP()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle($tsp.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tsp.traditionalBasePay) {
            validateTraditional()
        }
        .onChange(of: tsp.rothBasePay) {
            validateRoth()
        }
        .toolbar {
            ToolbarItem {
                Button("Delete Thrift Savings Plan", systemImage: "trash", role: .destructive) {
                    deleteTSP()
                    dismiss()
                }
            }
        }
    }
    
    private func deleteTSP() {
        modelContext.delete(tsp)
    }
    
    private func resetTSP() {
        tsp.traditionalBasePay = 0.00
        tsp.rothBasePay = 0.00
    }
    
    private func validateTraditional() {
        if tsp.traditionalBasePay.isZero {
            tsp.traditionalSpecialPay = 0.00
            tsp.traditionalIncentivePay = 0.00
            tsp.traditionalBonusPay = 0.00
        }
    }
    
    private func validateRoth() {
        if tsp.rothBasePay.isZero {
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
