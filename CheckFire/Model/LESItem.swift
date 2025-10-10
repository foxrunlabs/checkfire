import Foundation
import SwiftData

@Model
final class LESItem: Identifiable {
    var id = UUID()
    var name = ""
    var amount: Decimal = 0.00
    var type = LESItemType.specialPay
    var paycheck: Paycheck? = nil
    
    init(name: String, amount: Decimal, type: LESItemType, paycheck: Paycheck? = nil) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.type = type
        self.paycheck = paycheck
    }
    
    static let exampleEntitlement = LESItem(name: "Fly Pay", amount: 840.00, type: .incentivePay)
    static let exampleDeduction = LESItem(name: "SGLI", amount: 26.00, type: .deduction)
    static let exampleAllotment = LESItem(name: "Tricare Dental", amount: 29.98, type: .allotment)
}
