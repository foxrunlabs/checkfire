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
    
    static let shared = BASTables()
}
