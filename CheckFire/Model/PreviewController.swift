import Foundation
import SwiftData

@MainActor
class PreviewController {
    static let container: ModelContainer = {
        let paycheck = Paycheck.example
        paycheck.bah = 4485.00
        
        let lesItems: [LESItem] = [
            .init(name: "Fly Pay", amount: 840.00, type: .incentivePay, paycheck: paycheck),
            .init(name: "SGLI", amount: 31.00, type: .deduction, paycheck: paycheck),
            .init(name: "SGLI Family/Spouse", amount: 10.00, type: .deduction, paycheck: paycheck),
            .init(name: "Tricare Dental", amount: 29.98, type: .allotment, paycheck: paycheck)
        ]
        
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Paycheck.self, LESItem.self, WithholdingForm.self, ThriftSavingsPlan.self,
                configurations: config
            )
            
            container.mainContext.insert(WithholdingForm.example)
            container.mainContext.insert(ThriftSavingsPlan.example)
            container.mainContext.insert(paycheck)
            lesItems.forEach { container.mainContext.insert($0) }
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
