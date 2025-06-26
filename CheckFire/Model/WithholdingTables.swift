import Foundation

final class WithholdingTables {
    private let withholdingTables: [WithholdingTable] = Bundle.main.decode(from: "withholding_tables.json")
    
    var years: ClosedRange<Int> {
        let allYears = withholdingTables.map({ $0.year }).sorted()
        return allYears.first!...allYears.last!
    }
    
    /// Private initializer for singleton object.
    private init() {}
    
    /// Retrieve tax data for a specified year.
    /// - Parameter year: Tax year.
    /// - Returns: Tax data. If the data does not exist, the method returns `nil`.
    private func withholdingTable(for year: Int) -> WithholdingTable? {
        withholdingTables.first { $0.year == year }
    }
    
    /// Calculate Medicare tax.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - wage: Taxable wage in dollars.
    /// - Returns: Medicate tax owed in dollars.
    func calculateMedicare(for year: Int, wage: Decimal) -> Decimal? {
        if let table = withholdingTable(for: year) {
            (wage * table.medicareRate).rounded(.toNearestOrAwayFromZero, digits: 2)
        } else {
            nil
        }
    }
    
    /// Calculate Social Security tax.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - wage: Taxable wage in dollars.
    /// - Returns: Social Security tax owed.
    func calculateSocialSecurity(for year: Int, wage: Decimal) -> Decimal? {
        if let table = withholdingTable(for: year) {
            (wage * table.socialSecurityRate).rounded(.toNearestOrAwayFromZero, digits: 2)
        } else {
            nil
        }
    }
    
    /// Calculate federal income tax withholding for a wage using the percentage method for manual payroll systems.
    /// - Parameters:
    ///   - year: Calendar year.
    ///   - wage: Taxable wage in dollars.
    ///   - federalWithholdingData: Federal withholding data from myPay.
    /// - Returns: Federal income tax withholding in dollars.
    func calculateWithholding(
        for year: Int,
        wage: Decimal,
        using withholdingForm: WithholdingForm
    ) -> Decimal? {
        let wageFrequency: Decimal = 12
        
        // adjust the wage amount
        var adjustedWage = wage
        adjustedWage += withholdingForm.otherIncome / wageFrequency
        adjustedWage -= withholdingForm.deductions / wageFrequency
        adjustedWage = max(0.00, adjustedWage)
        
        // figure the tentative withholding amount
        guard let table = withholdingTable(for: year) else { return nil }
        
        let schedule: WithholdingSchedule = withholdingForm.multipleJobs ? .multipleJobs : .standard
        let brackets = table.taxBrackets[schedule]?[withholdingForm.maritalStatus]
        
        guard let bracket = brackets?.last(where: { adjustedWage >= $0.atLeast }) else { return nil }
        
        var withholding = bracket.tentativeAmount
        withholding += (adjustedWage - bracket.atLeast) * bracket.rate
        
        // account for tax credits
        var dependentCredits = Decimal(withholdingForm.childDependents) * table.childTaxCredit
        dependentCredits += Decimal(withholdingForm.otherDependents) * table.otherDependentTaxCredit
        withholding -= dependentCredits / wageFrequency
        withholding = max(0.00, withholding)
        
        // figure final withholding
        withholding += withholdingForm.extraWithholding
        return withholding.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    static let shared = WithholdingTables()
}
