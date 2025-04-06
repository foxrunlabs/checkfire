import Foundation

final class TaxYears {
    private let taxYearData: [TaxData] = Bundle.main.decode(from: "tax_data.json")
    
    var years: [Int] {
        taxYearData.map { $0.year }
    }
    
    private init() {}
    
    /// Retrieve tax data for a specified year.
    /// - Parameter year: Tax year.
    /// - Returns: Tax data. If the data does not exist, the method returns `nil`.
    func taxData(for year: Int) -> TaxData? {
        taxYearData.first { $0.year == year }
    }
    
    static let shared = TaxYears()
}
