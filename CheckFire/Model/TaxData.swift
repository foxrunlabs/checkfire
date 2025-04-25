import Foundation

struct TaxData: Decodable, Identifiable {
    let year: Int
    let childTaxCredit: Decimal
    let otherDependentTaxCredit: Decimal
    let medicareRate: Decimal
    let socialSecurityRate: Decimal
    let withholdingTables: [WithholdingSchedule: [MaritalStatus: [WithholdingData]]]
    
    // MARK: - Identifiable
    var id: Int { year }
    
    /// Calculate federal income tax withholding for a wage using the percentage method for manual payroll systems.
    /// - Parameter wage: Monthly taxable wage in dollars.
    /// - Parameter myPayData: myPay data.
    /// - Returns: Federal income tax withholding in dollars.
    func calculateWithholding(for wage: Decimal, using myPayData: MyPayData) -> Decimal {
        let wageFrequency: Decimal = 12
        
        // adjust the wage amount
        var adjustedWage = wage
        adjustedWage += myPayData.otherIncome / wageFrequency
        adjustedWage -= myPayData.deductions / wageFrequency
        adjustedWage = max(0.00, adjustedWage)
        
        // figure the tentative withholding amount
        let withholdingSchedule: WithholdingSchedule = myPayData.multipleJobs ? .multipleJobs : .standard
        guard let withholdingTable = withholdingTables[withholdingSchedule]?[myPayData.maritalStatus] else {
            fatalError("No withholding table found for \(myPayData.maritalStatus.description)")
        }
        
        guard let withholdingData = withholdingTable.last(where: { adjustedWage >= $0.atLeast }) else {
            fatalError("No withholding data found for \(adjustedWage.description)")
        }
        
        var withholding = withholdingData.tentativeAmount
        withholding += (adjustedWage - withholdingData.atLeast) * withholdingData.rate
        
        // account for tax credits
        var dependentCredits = Decimal(myPayData.childDependents) * childTaxCredit
        dependentCredits += Decimal(myPayData.otherDependents) * otherDependentTaxCredit
        withholding -= dependentCredits / wageFrequency
        withholding = max(0.00, withholding)
        
        // figure final withholding
        withholding += myPayData.extraWithholding
        return withholding.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
}
