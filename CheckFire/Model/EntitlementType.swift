import Foundation

enum EntitlementType: CaseIterable, Codable, CustomStringConvertible, Identifiable {
    case specialPay
    case incentivePay
    case bonusPay
    case allowance
    
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
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
