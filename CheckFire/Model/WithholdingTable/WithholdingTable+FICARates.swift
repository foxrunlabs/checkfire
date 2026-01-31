import Foundation

extension WithholdingTable {
    struct FICARates: Decodable {
        let medicare: Decimal
        let socialSecurity: Decimal
    }
}
