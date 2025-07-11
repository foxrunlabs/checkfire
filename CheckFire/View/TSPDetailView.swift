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
            
            Section {
                Button("Reset") {
                    resetTSP()
                }
                .frame(maxWidth: .infinity)
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
        tsp.traditionalBasicPay = 0.00
        tsp.rothBasicPay = 0.00
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
