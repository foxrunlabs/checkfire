import Foundation

enum LESItemType: CaseIterable, Codable, CustomStringConvertible, Hashable, Identifiable {
    static var allCases: [LESItemType] {
        EntitlementType.allCases.map(entitlement) + [.deduction, .allotment]
    }
    
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
