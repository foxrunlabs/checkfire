import Foundation

struct WithholdingTable: Decodable {
    let year: Int
    let taxCredits: TaxCredits
    let ficaRates: FICARates
    let taxBrackets: [Schedule: [MaritalStatus: [WithholdingData]]]
}
