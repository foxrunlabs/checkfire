import SwiftUI

struct PaycheckView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        TabView {
            Tab("LES", systemImage: "plus.forwardslash.minus") {
                LESDataView(paycheck: paycheck)
            }
            
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(paycheck: paycheck)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(paycheck: paycheck)
            }
            
            Tab("Net Pay", systemImage: "dollarsign") {
                NetPayView(paycheck: paycheck)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PaycheckView(paycheck: Paycheck.example)
}
