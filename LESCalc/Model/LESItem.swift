import Foundation

struct LESItem: Codable, Equatable, Identifiable {
    var id = UUID()
    var name = ""
    var amount: Decimal = 0.00
}
