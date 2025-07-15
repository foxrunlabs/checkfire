import Foundation

struct BAHTable: Decodable {
    let year: Int
    let mhas: [BAHData]
}
