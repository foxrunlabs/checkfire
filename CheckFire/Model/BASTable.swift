import Foundation

struct BASTable: Decodable {
    let year: Int
    let officer: Decimal
    let enlisted: Decimal
    let basII: Decimal
}
