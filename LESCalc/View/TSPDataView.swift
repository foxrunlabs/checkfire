import SwiftUI

struct TSPDataView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Section("Traditional TSP") {
                Stepper(
                    "Base Pay \(paycheck.tspData.traditionalTspPercentage.formatted(.percent))",
                    value: $paycheck.tspData.traditionalTspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
            
            Section("Roth TSP") {
                Stepper(
                    "Base Pay \(paycheck.tspData.rothTspPercentage.formatted(.percent))",
                    value: $paycheck.tspData.rothTspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    TSPDataView(paycheck: paycheck)
}
