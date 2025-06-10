import Foundation

enum LESItemType: Codable, CustomStringConvertible, Hashable, Identifiable {
    case entitlement(EntitlementType)
    case deduction
    case allotment
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .entitlement(let entitlementType):
            String(describing: entitlementType)
        case .deduction:
            "Deduction"
        case .allotment:
            "Allotment"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
