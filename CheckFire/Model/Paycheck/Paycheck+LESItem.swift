import Foundation

extension Paycheck {
    struct LESItem: Codable, Identifiable {
        var id: UUID = UUID()
        var name: String
        var amount: Decimal
        var category: Category
        
        // MARK: - Initializer
        init(_ name: String, amount: Decimal, category: Category) {
            self.name = name
            self.amount = amount
            self.category = category
        }
        
        // MARK: - Computed Properties
        var isEntitlement: Bool { Category.entitlementCases.contains(category) }
        var isTaxable: Bool { isEntitlement && category != .allowance }
    }
}


// MARK: - LES Item Category
extension Paycheck.LESItem {
    enum Category: String, CaseIterable, Codable, CustomStringConvertible, Identifiable {
        case specialPay
        case incentivePay
        case bonusPay
        case allowance
        case deduction
        case allotment
        
        // MARK: - Properties
        static let entitlementCases: [Self] = [.specialPay, .incentivePay, .bonusPay, .allowance]
        
        // MARK: - CustomStringConvertible
        var description: String {
            switch self {
            case .specialPay:
                "Special Pay"
            case .incentivePay:
                "Incentive Pay"
            case .bonusPay:
                "Bonus Pay"
            case .allowance:
                "Allowance"
            case .deduction:
                "Deduction"
            case .allotment:
                "Allotment"
            }
        }
        
        // MARK: - Identifiable
        var id: Self { self }
    }
}
