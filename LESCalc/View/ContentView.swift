import SwiftUI

struct ContentView: View {
    @State private var myPayData = MyPayData()
    @State private var lesData = LESData()

    var body: some View {
        TabView {
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(myPayData: $myPayData)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(myPayData: $myPayData)
            }
            
            Tab("LES Data", systemImage: "pencil.and.list.clipboard") {
                LESDataView(lesData: $lesData)
            }
            
            Tab("Net Pay", systemImage: "dollarsign") {
                NetPayView(lesData: lesData, myPayData: myPayData)
            }
        }
    }
}

#Preview {
    ContentView()
}
