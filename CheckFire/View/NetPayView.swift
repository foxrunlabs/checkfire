import Foundation
import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    
    @Environment(WithholdingTableRepository.self) private var withholdingTables
    
    // MARK: - Computed Properties
    private var taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)? {
        withholdingTables.table(for: paycheck.year)?.calculateTaxes(for: paycheck)
    }
    
    // MARK: - Body
    var body: some View {
        List {
            if let taxes {
                Section {
                    LabeledCurrency("Gross Pay", value: paycheck.grossPay)
                    LabeledCurrency("Wage Period", value: paycheck.wagePeriod)
                }
                
                Section {
                    LabeledCurrency("Traditional TSP", value: paycheck.tspContribution(.traditional))
                    LabeledCurrency("Roth TSP", value: paycheck.tspContribution(.roth))
                }
                
                Section {
                    LabeledCurrency("Federal Taxes", value: taxes.federal)
                    LabeledCurrency("Social Security", value: taxes.socialSecurity)
                    LabeledCurrency("Medicare", value: taxes.medicare)
                }
                
                Section {
                    LabeledCurrency("Net Pay", value: paycheck.netPay(taxes: taxes))
                }
            } else {
                ContentUnavailableView(
                    "No tax information available for \(paycheck.year)",
                    systemImage: "questionmark.text.page"
                )
                    
            }
        }
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        NetPayView(paycheck: Paycheck.example)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
