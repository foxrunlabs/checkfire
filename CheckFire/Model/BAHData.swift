import Foundation

struct BAHData: Decodable {
    let mha: String
    let description: String
    let withoutDependents: [PayGrade: Decimal]
    let withDependents: [PayGrade: Decimal]
}
