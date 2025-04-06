import SwiftUI

struct TSPDataView: View {
    @Binding var myPayData: MyPayData
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Traditional TSP") {
                    Stepper(
                        "Base Pay \(myPayData.tspPercentage.formatted(.percent))",
                        value: $myPayData.tspPercentage,
                        in: 0...0.20,
                        step: 0.01,
                        format: .percent
                    )
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Thrift Savings Plan")
            .toolbarTitleDisplayMode(UIDevice.isiPad ? .large : .inline)
        }
    }
}

#Preview {
    @Previewable @State var myPayData = MyPayData()
    TSPDataView(myPayData: $myPayData)
}
