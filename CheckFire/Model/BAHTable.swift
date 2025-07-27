import Foundation

struct BAHTable: Decodable {
    typealias ZIPCode = String
    typealias MHA = String
    typealias MHAName = String
    
    let year: Int
    let mhas: [ZIPCode: MHA]
    let mhaNames: [MHA: MHAName]
    let rates: [MHA: BAHData]
}
