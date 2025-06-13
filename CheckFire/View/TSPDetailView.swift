import SwiftData
import SwiftUI

struct TSPDetailView: View {
    @Bindable var tsp: ThriftSavingsPlan
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

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
                Stepper(
                    value: $tsp.traditionalBasePay,
                    in: 0.00...(1 - tsp.rothBasePay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Base Pay")
                        Spacer()
                        Text(tsp.traditionalBasePay.formatted(.percent))
                    }
                }
                
                Stepper(
                    value: $tsp.traditionalSpecialPay,
                    in: 0.00...(1 - tsp.rothSpecialPay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Special Pay")
                        Spacer()
                        Text(tsp.traditionalSpecialPay.formatted(.percent))
                    }
                }
                .disabled(tsp.traditionalBasePay.isZero)
                
                Stepper(
                    value: $tsp.traditionalIncentivePay,
                    in: 0.00...(1 - tsp.rothIncentivePay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Incentive Pay")
                        Spacer()
                        Text(tsp.traditionalIncentivePay.formatted(.percent))
                    }
                }
                .disabled(tsp.traditionalBasePay.isZero)
                
                Stepper(
                    value: $tsp.traditionalBonusPay,
                    in: 0.00...(1 - tsp.rothBonusPay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Bonus Pay")
                        Spacer()
                        Text(tsp.traditionalBonusPay.formatted(.percent))
                    }
                }
                .disabled(tsp.traditionalBasePay.isZero)
            }

            Section("Roth TSP") {
                Stepper(
                    value: $tsp.rothBasePay,
                    in: 0.00...(1 - tsp.traditionalBasePay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Base Pay")
                        Spacer()
                        Text(tsp.rothBasePay.formatted(.percent))
                    }
                }

                Stepper(
                    value: $tsp.rothSpecialPay,
                    in: 0.00...(1 - tsp.traditionalSpecialPay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Special Pay")
                        Spacer()
                        Text(tsp.rothSpecialPay.formatted(.percent))
                    }
                }
                .disabled(tsp.rothBasePay.isZero)

                Stepper(
                    value: $tsp.rothIncentivePay,
                    in: 0.00...(1 - tsp.traditionalIncentivePay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Incentive Pay")
                        Spacer()
                        Text(tsp.rothIncentivePay.formatted(.percent))
                    }
                }
                .disabled(tsp.rothBasePay.isZero)

                Stepper(
                    value: $tsp.rothBonusPay,
                    in: 0.00...(1 - tsp.traditionalBonusPay),
                    step: 0.01
                ) {
                    HStack {
                        Text("Bonus Pay")
                        Spacer()
                        Text(tsp.rothBonusPay.formatted(.percent))
                    }
                }
                .disabled(tsp.rothBasePay.isZero)
            }
            
            Section {
                Button("Reset") {
                    tsp.traditionalBasePay = 0.00
                    tsp.traditionalSpecialPay = 0.00
                    tsp.traditionalIncentivePay = 0.00
                    tsp.traditionalBonusPay = 0.00

                    tsp.rothBasePay = 0.00
                    tsp.rothSpecialPay = 0.00
                    tsp.rothIncentivePay = 0.00
                    tsp.rothBonusPay = 0.00
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle($tsp.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: tsp.traditionalBasePay) {
            if tsp.traditionalBasePay.isZero {
                tsp.traditionalSpecialPay = 0.00
                tsp.traditionalIncentivePay = 0.00
                tsp.traditionalBonusPay = 0.00
            }
        }
        .onChange(of: tsp.rothBasePay) {
            if tsp.rothBasePay.isZero {
                tsp.rothSpecialPay = 0.00
                tsp.rothIncentivePay = 0.00
                tsp.rothBonusPay = 0.00
            }
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
}

// MARK: - Preview
#Preview {
    @Previewable @State var tsp = ThriftSavingsPlan.example
    
    NavigationStack {
        TSPDetailView(tsp: tsp)
    }
}
