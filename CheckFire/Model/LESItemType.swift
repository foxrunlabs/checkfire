import Foundation

enum LESItemType: CaseIterable, Codable, CustomStringConvertible, Hashable, Identifiable {
    case specialPay
    case incentivePay
    case bonusPay
    case allowance
    case deduction
    case allotment
    
    static let entitlementCases: [LESItemType] = [.specialPay, .incentivePay, .bonusPay, .allowance]
    var isEntitlement: Bool { self != .deduction && self != .allotment }
    
    // MARK: - Custom String Convertible
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
