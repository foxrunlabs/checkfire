import Foundation
import SwiftData

@Model
final class LESItem: Identifiable {
    var id = UUID()
    var name = ""
    
    var amount: Decimal = 0.00
    var itemType = LESItemType.entitlement(.specialPay)
    
    var paycheck: Paycheck? = nil
    
    init(name: String, amount: Decimal, itemType: LESItemType, paycheck: Paycheck? = nil) {
        self.id = UUID()
        self.name = name
        
        self.amount = amount
        self.itemType = itemType
        
        self.paycheck = paycheck
    }
}
