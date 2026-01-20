import Foundation
import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    @Environment(WithholdingTableRepository.self) private var withholdingTables
    @State private var withholdingTable: WithholdingTable?
    
    // MARK: - Computed Properties
    private var federalTaxes: Decimal {
        withholdingTable?.calculateWithholding(for: paycheck) ?? 0.00
    }
    
    private var medicare: Decimal {
        withholdingTable?.calculateMedicare(for: paycheck) ?? 0.00
    }
    
    private var socialSecurity: Decimal {
        withholdingTable?.calculateSocialSecurity(for: paycheck) ?? 0.00
    }
    
    private var netPay: Decimal {
        var net = paycheck.grossPay
        net -= paycheck.traditionalTSPContribution
        net -= paycheck.rothTSPContribution
        net -= federalTaxes
        net -= medicare
        net -= socialSecurity        
        net -= paycheck.lesItems.filter { !$0.isEntitlement }.reduce(0.00) { $0 + $1.amount }
        return net
    }
    
    // MARK: - Body
    var body: some View {
        List {
            Group {
                Section {
                    LabeledCurrency("Gross Pay", value: paycheck.grossPay)
                    LabeledCurrency("Wage Period", value: paycheck.wagePeriod)
                }
                
                Section {
                    LabeledCurrency("Traditional TSP", value: paycheck.traditionalTSPContribution)
                    LabeledCurrency("Roth TSP", value: paycheck.rothTSPContribution)
                }
                
                Section {
                    LabeledCurrency("Federal Taxes", value: federalTaxes)
                    LabeledCurrency("Social Security", value: socialSecurity)
                    LabeledCurrency("Medicare", value: medicare)
                }
                
                Section {
                    LabeledCurrency("Net Pay", value: netPay)
                }
            }
        }
        .onAppear {
            withholdingTable = withholdingTables.table(for: paycheck.year)
        }
    }
}


// MARK: - Labeled Currency
extension NetPayView {
    private struct LabeledCurrency<S: StringProtocol>: View {
        let title: S
        let value: Decimal
        
        // MARK: - Initializer
        init(_ title: S, value: Decimal) {
            self.title = title
            self.value = value
        }
        
        //MARK: - Body
        var body: some View {
            LabeledContent(title) {
                Text(value, format: .currency(code: "USD"))
            }
        }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        NetPayView(paycheck: paycheck)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
