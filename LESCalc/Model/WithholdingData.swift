import Foundation

struct WithholdingData: Codable {
    let atLeast: Decimal
    let tentativeAmount: Decimal
    let rate: Decimal
}
