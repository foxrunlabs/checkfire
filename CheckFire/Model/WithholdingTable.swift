import Foundation

struct WithholdingTable: Decodable {
    let year: Int
    let childTaxCredit: Decimal
    let otherDependentTaxCredit: Decimal
    let medicareRate: Decimal
    let socialSecurityRate: Decimal
    let taxBrackets: [WithholdingSchedule: [MaritalStatus: [WithholdingData]]]
}
