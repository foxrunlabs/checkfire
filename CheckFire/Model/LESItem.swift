import Foundation

struct LESItem: Codable, Equatable, Identifiable {
    let id = UUID()
    var name: String
    var amount: Decimal
    var itemType: LESItemType
    
    var isEntitlement: Bool {
        // Does not include base pay.
        itemType != .basePay && itemType != .deduction && itemType != .allotment
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case itemType
    }
}
