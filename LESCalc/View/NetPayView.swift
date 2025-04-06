import SwiftUI

struct NetPayView: View {
    let lesData: LESData
    let myPayData: MyPayData
    
    var body: some View {
        List {
            TextLabel(label: "Gross Pay:", value: lesData.grossPay)
            
            TextLabel(label: "TSP Contribution:", value: lesData.tspContribution(using: myPayData))
            
            TextLabel(label: "Wage Period:", value: lesData.wagePeriod(using: myPayData))
            
            TextLabel(label: "Federal Taxes:", value: lesData.federalTaxes(using: myPayData))
            
            TextLabel(label: "Medicare:", value: lesData.medicare(using: myPayData))
            
            TextLabel(label: "Social Security:", value: lesData.socialSecurity(using: myPayData))
            
            TextLabel(label: "Net Pay:", value: lesData.netPay(using: myPayData))
        }
        .listStyle(.sidebar)
    }
    
    private struct TextLabel: View {
        let label: String
        let value: Decimal
        
        var body: some View {
            HStack {
                Text(label)
                
                Spacer()
                
                Text(value.formatted(.currency(code: "USD")))
            }
        }
    }
}

#Preview {
    NetPayView(lesData: LESData(), myPayData: MyPayData())
}
