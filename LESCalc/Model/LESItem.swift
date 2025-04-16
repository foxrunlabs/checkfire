import Foundation

struct LESItem: Codable, Equatable, Identifiable {
    var id = UUID()
    var name = ""
    var amount: Decimal = 0.00
    
    static let example = LESItem(name: "Example", amount: 31.00)
}
