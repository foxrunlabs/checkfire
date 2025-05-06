import Foundation

enum LESItemType: String, Codable, CustomStringConvertible, Identifiable {
    case basePay
    case specialPay
    case incentivePay
    case bonusPay
    case allowance
    case deduction
    case allotment
    
    static var entitlements: [Self] { [.specialPay, .incentivePay, .bonusPay, .allowance] }
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .basePay:
            "Base Pay"
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
