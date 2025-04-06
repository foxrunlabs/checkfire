import SwiftUI

struct TSPDataView: View {
    @Binding var myPayData: MyPayData
    
    var body: some View {
        Form {
            Section("Traditional TSP") {
                Stepper(
                    "Base Pay",
                    value: $myPayData.tspPercentage,
                    in: 0...0.20,
                    step: 0.01,
                    format: .percent
                )
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    TSPDataView(myPayData: .constant(MyPayData()))
}
