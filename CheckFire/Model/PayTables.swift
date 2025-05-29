import Foundation

final class PayTables {
    private let payTables: [PayTable] = Bundle.main.decode(from: "pay_tables.json")
    
    var years: [Int] {
        payTables.map { $0.year } 
    }
    
    /// Private initializer for singleton object.
    private init() {}
    
    private func payTable(for year: Int) -> PayTable? {
        payTables.first { $0.year == year }
    }
    
    /// Base pay for pay grade and years of service.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - grade: Pay grade.
    ///   - yearsOfService: Cumulative years of service.
    /// - Returns: Base pay in dollars or `nil` if data no available.
    func basePay(
        for year: Int,
        as grade: PayGrade,
        with yearsOfService: YearsOfService
    ) -> Decimal? {
        let table = payTable(for: year)
        let schedule = table?.schedule[grade]
        return schedule?[yearsOfService] ?? nil
    }
    
    /// Selectable years of service for a pay grade.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - grade: Pay grade.
    /// - Returns: Array of cumulative years of service available for a pay grade.
    func yearsOfServiceAvailable(for year: Int, as grade: PayGrade) -> [YearsOfService] {
        let table = payTable(for: year)
        let schedule = table?.schedule[grade] ?? [:]
        return YearsOfService.allCases.filter { schedule.keys.contains($0) }
    }
    
    static let shared = PayTables()
}
