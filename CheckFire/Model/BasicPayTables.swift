import Foundation

final class BasicPayTables {
    private let payTables: [BasicPayTable] = Bundle.main.decode(from: "basic_pay_tables.json")
    
    var years: [Int] {
        payTables.map { $0.year } 
    }
    
    /// Private initializer for singleton object.
    private init() {}
    
    func payTable(for year: Int) -> BasicPayTable? {
        payTables.first { $0.year == year }
    }
    
    /// Basic pay for a given paycheck.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - grade: Pay grade.
    ///   - yearsOfService: Years of cumulative service.
    /// - Returns: Basic pay `Decimal`, or `nil` if unable to compute.
    func basicPay(
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
    
    static let shared = BasicPayTables()
}
