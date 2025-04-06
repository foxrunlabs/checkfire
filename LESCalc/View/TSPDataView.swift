import SwiftUI

struct TSPDataView: View {
    @Binding var myPayData: MyPayData
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Traditional TSP") {
                    Stepper(
                        "Base Pay \(myPayData.traditionalTspPercentage.formatted(.percent))",
                        value: $myPayData.traditionalTspPercentage,
                        in: 0...0.20,
                        step: 0.01,
                        format: .percent
                    )
                }
                
                Section("Roth TSP") {
                    Stepper(
                        "Base Pay \(myPayData.rothTspPercentage.formatted(.percent))",
                        value: $myPayData.rothTspPercentage,
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
    @Previewable @State var myPayData = MyPayData.example
    TSPDataView(myPayData: $myPayData)
}
