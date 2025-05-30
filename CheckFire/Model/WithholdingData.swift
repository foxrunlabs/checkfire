import Foundation

struct WithholdingData: Decodable {
    let atLeast: Decimal
    let tentativeAmount: Decimal
    let rate: Decimal
}
