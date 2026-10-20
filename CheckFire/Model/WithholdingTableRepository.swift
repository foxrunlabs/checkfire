import Foundation
import Observation

@Observable
final class WithholdingTableRepository {
    typealias Year = Int
    
    private let tablesByYear: [Year: WithholdingTable]
    
    // MARK: - Computed Properties
    
    var years: ClosedRange<Year> {
        let allYears = tablesByYear.keys.sorted()
        
        guard
            let first = allYears.first,
            let last = allYears.last
        else {
            preconditionFailure("WithholdingTableRepository has no tables loaded.")
        }
        
        return first...last
    }
    
    // MARK: - Initializer
    
    init(from source: String) {
        let tables: [WithholdingTable] = Bundle.main.decode(from: source)
        self.tablesByYear = Dictionary(uniqueKeysWithValues: tables.map { ($0.year, $0) })
    }
    
    // MARK: - Methods
    
    /// Retrieve withholding table for a specified year.
    /// - Parameter year: Tax year.
    /// - Returns: Withholding table, or`nil` if the table does not exist.
    func table(for year: Year) -> WithholdingTable? {
        tablesByYear[year]
    }
}
