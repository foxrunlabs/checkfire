import SwiftUI

struct NetPayView: View {
    let lesData: LESData
    let myPayData: MyPayData
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent {
                        Text(lesData.grossPay.formatted(.currency(code: "USD")))
                    } label: {
                        Text("Gross Pay")
                    }
                }
                
                Section {
                    LabeledContent {
                        Text(lesData.tspContribution(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("TSP Contribution")
                    }
                    
                    LabeledContent {
                        Text(lesData.wagePeriod(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("Wage Period")
                    }
                }
                
                Section {
                    LabeledContent {
                        Text(lesData.federalTaxes(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("Federal Taxes")
                    }
                    
                    LabeledContent {
                        Text(lesData.medicare(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("Medicare")
                    }
                    
                    LabeledContent {
                        Text(lesData.socialSecurity(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("Social Security")
                    }
                }
                
                Section {
                    LabeledContent {
                        Text(lesData.netPay(using: myPayData).formatted(.currency(code: "USD")))
                    } label: {
                        Text("Net Pay")
                    }
                }
            }
            .navigationTitle("Net Pay")
            .navigationBarTitleDisplayMode(UIDevice.isiPad ? .large : .inline)
        }
    }
}

#Preview {
    let lesData = LESData()
    let myPayData = MyPayData()
    NetPayView(lesData: lesData, myPayData: myPayData)
}
