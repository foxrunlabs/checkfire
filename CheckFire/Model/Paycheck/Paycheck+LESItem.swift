import Foundation

extension Paycheck {
    struct LESItem: Codable, Identifiable {
        var id: UUID = UUID()
        var name: String
        var amount: Decimal
        var category: Category
        
        // MARK: - Computed Properties
        
        var isEntitlement: Bool { Category.entitlementCases.contains(category) }
        var isTaxable: Bool { isEntitlement && category != .allowance }
        
        // MARK: - Initializer
        
        init(_ name: String, amount: Decimal, category: Category) {
            self.name = name
            self.amount = amount
            self.category = category
        }
    }
}


// MARK: - LES Item Category

extension Paycheck.LESItem {
    enum Category: String, CaseIterable, Codable, Identifiable {
        case allowance
        case bonusPay
        case incentivePay
        case specialPay
        case deduction
        case allotment
        
        // MARK: - Properties
        
        static let entitlementCases: [Self] = [.allowance, .bonusPay, .incentivePay, .specialPay]
        static let adjustmentCases: [Self] = [.deduction, .allotment]
        
        // MARK: - Computed Properties
        
        var displayName: String {
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
