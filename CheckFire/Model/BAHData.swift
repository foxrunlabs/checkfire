import Foundation

struct BAHData: Decodable {
    let withoutDependents: [PayGrade: Decimal]
    let withDependents: [PayGrade: Decimal]
}
