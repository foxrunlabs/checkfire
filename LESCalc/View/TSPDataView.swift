import SwiftUI

struct TSPDataView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Section("Traditional TSP") {
                Stepper(
                    "Base Pay \(paycheck.myPayData.traditionalTspPercentage.formatted(.percent))",
                    value: $paycheck.myPayData.traditionalTspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
            
            Section("Roth TSP") {
                Stepper(
                    "Base Pay \(paycheck.myPayData.rothTspPercentage.formatted(.percent))",
                    value: $paycheck.myPayData.rothTspPercentage,
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
