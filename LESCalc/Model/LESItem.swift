import Foundation

struct LESItem: Codable, Identifiable {
    var id = UUID()
    var name = ""
    var amount: Decimal = 0.00
}
