import SwiftUI

struct PaycheckView: View {
    let paycheck: Paycheck
    
    @State private var name = ""
    @State private var lesData = LESData()
    @State private var myPayData = MyPayData()
    @State private var tspData = TSPData()
    
    private var isUndoAndSaveEnabled: Bool {
        (name != paycheck.name) || (lesData != paycheck.lesData) ||
            (myPayData != paycheck.myPayData) || (tspData != paycheck.tspData)
    }
    
    var body: some View {
        TabView {
            Tab("LES", systemImage: "plus.forwardslash.minus") {
                LESDataView(lesData: $lesData)
            }
            
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(myPayData: $myPayData)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(tspData: $tspData)
            }
            
            Tab("Net Pay", systemImage: "dollarsign") {
                NetPayView(paycheck: paycheck)
            }
        }
        .navigationTitle($name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                Button("Undo", systemImage: "arrow.uturn.backward.circle") {
                    withAnimation {
                        name = paycheck.name
                        lesData = paycheck.lesData
                        myPayData = paycheck.myPayData
                        tspData = paycheck.tspData
                    }
                }
                .disabled(!isUndoAndSaveEnabled)
                
                Button("Save", systemImage: "checkmark.circle") {
                    withAnimation {
                        paycheck.name = name
                        paycheck.lesData = lesData
                        paycheck.myPayData = myPayData
                        paycheck.tspData = tspData
                    }
                }
                .disabled(!isUndoAndSaveEnabled)
            }
        }
        .onAppear {
            name = paycheck.name
            lesData = paycheck.lesData
            myPayData = paycheck.myPayData
            tspData = paycheck.tspData
        }
    }
}

#Preview {
    PaycheckView(paycheck: Paycheck.example)
}
