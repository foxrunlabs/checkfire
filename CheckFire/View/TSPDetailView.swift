import SwiftUI

struct TSPDetailView: View {
    @Bindable var tsp: ThriftSavingsPlan

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
                TSPStepper("Base Pay", value: $tsp.traditionalBasePay)

                TSPStepper("Special Pay", value: $tsp.traditionalSpecialPay)
                    .disabled(tsp.traditionalBasePay == 0)

                TSPStepper("Incentive Pay", value: $tsp.traditionalIncentivePay)
                    .disabled(tsp.traditionalBasePay == 0)

                TSPStepper("Bonus Pay", value: $tsp.traditionalBonusPay)
                    .disabled(tsp.traditionalBasePay == 0)
            }

            Section("Roth TSP") {
                TSPStepper("Base Pay", value: $tsp.rothBasePay)

                TSPStepper("Special Pay", value: $tsp.rothSpecialPay)
                    .disabled(tsp.rothBasePay == 0)

                TSPStepper("Incentive Pay", value: $tsp.rothIncentivePay)
                    .disabled(tsp.rothBasePay == 0)

                TSPStepper("Bonus Pay", value: $tsp.rothBonusPay)
                    .disabled(tsp.rothBasePay == 0)
            }
        }
        .navigationTitle($tsp.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tsp = ThriftSavingsPlan.example
    
    NavigationStack {
        TSPDetailView(tsp: tsp)
    }
}
