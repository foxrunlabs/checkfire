import Foundation

struct LESItem: Codable, Equatable, Identifiable {
    let id = UUID()
    var name: String
    var amount: Decimal
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name
        case amount
    }
}
