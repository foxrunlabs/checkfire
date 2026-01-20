import Foundation

struct WithholdingTable: Decodable {
    typealias Year = Int
    
    let year: Year
    let taxCredits: TaxCredits
    let ficaRates: FICARates
    let taxBrackets: [WithholdingSchedule: [MaritalStatus: [WithholdingData]]]
    
    // MARK: - Methods
    /// Calculate Medicare tax for a paycheck.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Medicare tax owed in dollars.
    func calculateMedicare(for paycheck: Paycheck) -> Decimal {
        (paycheck.ficaWages * ficaRates.medicare).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Calculate Social Security tax for a paycheck.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Social Security tax owed.
    func calculateSocialSecurity(for paycheck: Paycheck) -> Decimal {
        (paycheck.ficaWages * ficaRates.socialSecurity).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Calculate federal income tax withholding for a paycheck using the percentage method for manual payroll systems.
    /// - Parameters:
    ///   - paycheck: Paycheck for calculation.
    /// - Returns: Federal income tax withholding in dollars.
    func calculateWithholding(for paycheck: Paycheck) -> Decimal? {
        let wageFrequency: Decimal = 12
        
        // adjust the wage amount
        var adjustedWage = paycheck.wagePeriod
        adjustedWage += paycheck.withholdingForm.otherIncome / wageFrequency
        adjustedWage -= paycheck.withholdingForm.deductions / wageFrequency
        adjustedWage = max(0.00, adjustedWage)
        
        // calculate the tentative withholding amount
        let schedule: WithholdingSchedule = paycheck.withholdingForm.multipleJobs ? .multipleJobs : .standard
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


// MARK: - Tax Credits
extension WithholdingTable {
    struct TaxCredits: Decodable {
        let child: Decimal
        let otherDependent: Decimal
    }
}


// MARK: - FICA Rates
extension WithholdingTable {
    struct FICARates: Decodable {
        let medicare: Decimal
        let socialSecurity: Decimal
    }
}


// MARK: - Withholding Schedule
extension WithholdingTable {
    enum WithholdingSchedule: String, Decodable, CodingKeyRepresentable {
        case standard
        case multipleJobs
    }
}


// MARK: - Withholding Data
extension WithholdingTable {
    struct WithholdingData: Decodable {
        let atLeast: Decimal
        let tentativeAmount: Decimal
        let rate: Decimal
    }
}
