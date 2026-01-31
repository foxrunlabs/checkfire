import Foundation

extension WithholdingTable {
    struct WithholdingData: Decodable {
        let atLeast: Decimal
        let tentativeAmount: Decimal
        let rate: Decimal
    }
}
