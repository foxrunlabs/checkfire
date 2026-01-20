import Foundation
import Observation

@Observable
final class WithholdingTableRepository {
    typealias Year = Int
    
    private let tables: [WithholdingTable]
    
    // MARK: - Initializer
    init(from source: String) {
        self.tables = Bundle.main.decode(from: source)
    }
    
    // MARK: - Computed Properties
    var years: ClosedRange<Year> {
        let allYears = tables.map({ $0.year }).sorted()
        return allYears.first!...allYears.last!
    }
    
    // MARK: - Methods
    /// Retrieve withholding table for a specified year.
    /// - Parameter year: Tax year.
    /// - Returns: Withholding table, or`nil` if the table does not exist.
    func table(for year: Year) -> WithholdingTable? {
        tables.first { $0.year == year }
    }
}
