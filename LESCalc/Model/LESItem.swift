import Foundation

struct LESItem: Codable, Equatable, Identifiable {
    let id = UUID()
    var name: String
    var amount: Decimal
    
    init(name: String, amount: Decimal) {
        self.name = name
        self.amount = amount
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case amount
    }
    
    static let example = LESItem(name: "Example", amount: 31.00)
}
