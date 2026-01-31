import Foundation

extension WithholdingTable {
    struct TaxCredits: Decodable {
        let child: Decimal
        let otherDependent: Decimal
    }
}
