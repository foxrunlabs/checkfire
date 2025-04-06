import SwiftUI

struct PaycheckView: View {
    let paycheck: Paycheck
    
    var body: some View {
        TabView {
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(paycheck: paycheck)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(paycheck: paycheck)
            }
            
            Tab("Pay Period", systemImage: "dollarsign") {
                LESDataView(paycheck: paycheck)
            }
            
            Tab("Net Pay", systemImage: "banknote") {
                NetPayView(paycheck: paycheck)
            }
        }
        .navigationTitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PaycheckView(paycheck: Paycheck.example)
}
