import Foundation

final class BASTables {
    private let basTables: [BASTable] = Bundle.main.decode(from: "bas_tables.json")
    
    var years: [Int] {
        basTables.map { $0.year }
    }
    
    /// Private initializer for singleton object.
    private init() {}
    
    func basTable(for year: Int) -> BASTable? {
        basTables.first { $0.year == year }
    }
    
    func bas(for year: Int, as payGrade: PayGrade) -> Decimal? {
        guard let table = basTable(for: year) else { return nil }
        return payGrade.isEnlisted ? table.enlisted : table.officer
    }
    
    static let shared = BASTables()
}
