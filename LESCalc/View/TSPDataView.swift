import SwiftUI

struct TSPDataView: View {
    @Binding var tspData: TSPData
    
    var body: some View {
        Form {
            Section("Traditional TSP") {
                Stepper(
                    "Base Pay \(tspData.traditionalTspPercentage.formatted(.percent))",
                    value: $tspData.traditionalTspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
            
            Section("Roth TSP") {
                Stepper(
                    "Base Pay \(tspData.rothTspPercentage.formatted(.percent))",
                    value: $tspData.rothTspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var tspData = Paycheck.example.tspData
    TSPDataView(tspData: $tspData)
}
