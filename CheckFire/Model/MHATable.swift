import Foundation

struct MHATable: Decodable {
    let year: Int
    let mhas: [MHAData]
}
