import Foundation

struct WithholdingTable: Decodable {
    typealias Year = Int
    
    let year: Year
    let taxCredits: TaxCredits
    let ficaRates: FICARates
    let taxBrackets: [Schedule: [MaritalStatus: [WithholdingData]]]
    
    // MARK: - Methods
    
    /// Calculate federal withholding and FICA taxes for a paycheck.
    /// - Parameter paycheck: Paycheck for calculation.
    /// - Returns: Tuple `(federal?, medicare, socialSecurity)` representing taxes withheld.
    func calculateTaxes(for paycheck: Paycheck) -> (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)? {
        guard let federal = calculateWithholding(for: paycheck) else { return nil }
        let socialSecurity = calculateSocialSecurity(for: paycheck)
        let medicare = calculateMedicare(for: paycheck)
        return (federal, socialSecurity, medicare)
    }
    
    /// Calculate Medicare tax for a paycheck.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Medicare tax owed in dollars.
    private func calculateMedicare(for paycheck: Paycheck) -> Decimal {
        (paycheck.ficaWages * ficaRates.medicare).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Calculate Social Security tax for a paycheck.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Social Security tax owed.
    private func calculateSocialSecurity(for paycheck: Paycheck) -> Decimal {
        (paycheck.ficaWages * ficaRates.socialSecurity).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Calculate federal income tax withholding for a paycheck using the percentage method for manual payroll systems.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Federal income tax withholding in dollars.
    private func calculateWithholding(for paycheck: Paycheck) -> Decimal? {
        let wageFrequency: Decimal = 12
        
        // adjust the wage amount
        var adjustedWage = paycheck.wagePeriod
        adjustedWage += paycheck.withholdingForm.otherIncome / wageFrequency
        adjustedWage -= paycheck.withholdingForm.deductions / wageFrequency
        adjustedWage = max(0.00, adjustedWage)
        
        // calculate the tentative withholding amount
        let schedule: Schedule = paycheck.withholdingForm.multipleJobs ? .multipleJobs : .standard
        let brackets = taxBrackets[schedule]?[paycheck.withholdingForm.maritalStatus]
        guard let bracket = brackets?.last(where: { adjustedWage >= $0.atLeast }) else { return nil }
        var withholding = bracket.tentativeAmount + (adjustedWage - bracket.atLeast) * bracket.rate
        
        // account for tax credits
        var dependentCredits = Decimal(paycheck.withholdingForm.childDependents) * taxCredits.child
        dependentCredits += Decimal(paycheck.withholdingForm.otherDependents) * taxCredits.otherDependent
        withholding -= dependentCredits / wageFrequency
        withholding = max(0.00, withholding)
        
        // calculate final withholding
        withholding += paycheck.withholdingForm.extraWithholding
        return withholding.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
}
