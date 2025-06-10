import Foundation
import SwiftData

@MainActor
class PreviewController {
    static let container: ModelContainer = {
        let paycheck = Paycheck.example
        let lesItems: [LESItem] = [
            .init(name: "Fly Pay", amount: 840.00, itemType: .entitlement(.incentivePay), paycheck: paycheck),
            .init(name: "BAH", amount: 4485.00, itemType: .entitlement(.allowance), paycheck: paycheck),
            .init(name: "BAS", amount: 320.78, itemType: .entitlement(.allowance), paycheck: paycheck),
            .init(name: "SGLI", amount: 31.00, itemType: .deduction, paycheck: paycheck),
            .init(name: "SGLI Family/Spouse", amount: 10.00, itemType: .deduction, paycheck: paycheck),
            .init(name: "Tricare Dental", amount: 29.98, itemType: .allotment, paycheck: paycheck)
        ]
        paycheck.lesItems?.append(contentsOf: lesItems)
        
        let withholdingForm = WithholdingForm.example
        let thriftSavingsPlan = ThriftSavingsPlan.example
        
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Paycheck.self, LESItem.self, WithholdingForm.self, ThriftSavingsPlan.self,
                configurations: config)
            
            container.mainContext.insert(paycheck)
            lesItems.forEach { container.mainContext.insert($0) }
            container.mainContext.insert(withholdingForm)
            container.mainContext.insert(thriftSavingsPlan)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }()
}
