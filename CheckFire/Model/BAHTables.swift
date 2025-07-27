import Foundation

final class BAHTables {
    private let bahTables: [BAHTable] = Bundle.main.decode(from: "bah_tables.json")
    
    var years: [Int] {
        bahTables.map { $0.year }
    }
    
    /// Private initializer for singleton object.
    private init() {}
    
    /// Military Housing Area (MHA) name for a given year and ZIP code.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - zipcode: ZIP code.
    /// - Returns: MHA name.
    func mhaName(for year: Int, in zipcode: String) -> String? {
        let bahTable = bahTables.first { $0.year == year }
        guard let mha = bahTable?.mhas[zipcode] else { return nil }
        return bahTable?.mhaNames[mha]
    }
    
    /// Basic Allowance for Housing (BAH) for a given year, ZIP code, pay grade, and dependent status.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - zipcode: ZIP code.
    ///   - payGrade: Pay grade.
    ///   - withDependents: Dependents status.
    /// - Returns: BAH `Decimal`, or `nil` if unable to compute.
    func bah(
        for year: Int,
        in zipcode: String,
        as payGrade: PayGrade,
        withDependents: Bool
    ) -> Decimal? {
        let bahTable = bahTables.first { $0.year == year }
        guard let mha = bahTable?.mhas[zipcode] else { return nil }
        let bahData = bahTable?.rates[mha]
        return withDependents ? bahData?.withDependents[payGrade] : bahData?.withoutDependents[payGrade]
    }
    
    static let shared = BAHTables()
}
