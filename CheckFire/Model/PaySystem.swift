import Foundation
import Observation

@Observable
final class PaySystem {
    struct PaycheckResult: Equatable {
        let grossPay: Decimal
        let federalTaxableWages: Decimal
        let ficaWages: Decimal

        let traditionalTSP: Decimal
        let rothTSP: Decimal

        let federalWithholding: Decimal
        let socialSecurity: Decimal
        let medicare: Decimal

        let adjustments: Decimal

        let netPay: Decimal
        
        // MARK: - Computed Methods
        
        var totalTSP: Decimal { traditionalTSP + rothTSP }
        var totalTax: Decimal { federalWithholding + socialSecurity + medicare }
    }
    
    private let withholdingTables: [Int: WithholdingTable]
    
    // MARK: - Computed Properties
    
    var taxYears: ClosedRange<Int> {
        let allYears = withholdingTables.keys.sorted()
        
        guard
            let first = allYears.first,
            let last = allYears.last
        else {
            preconditionFailure("PaySystem has no tables loaded.")
        }
        
        return first...last
    }
    
    // MARK: - Initializer
    
    init(from source: String) {
        let tables: [WithholdingTable] = Bundle.main.decode(from: source)
        self.withholdingTables = Dictionary(uniqueKeysWithValues: tables.map { ($0.year, $0) })
    }
    
    // MARK: - Methods
    
    func calculate(_ paycheck: Paycheck) throws -> PaycheckResult {
        let grossPay = paycheck.basicPay + paycheck.entitlements.sum(\.amount)
        
        // TSP contributions
        let traditionalTSP = tspContribution(paycheck, type: .traditional)
        let rothTSP = tspContribution(paycheck, type: .roth)
        
        // taxable wages
        let federalTaxableWages = paycheck.basicPay + paycheck.taxableLESItems.sum(\.amount) - traditionalTSP
        let ficaWages = paycheck.basicPay
        
        // adjust the wage amount based on W-4 data
        var adjustedWage = federalTaxableWages
        adjustedWage += paycheck.withholdingForm.otherIncome / Paycheck.wageFrequency
        adjustedWage -= paycheck.withholdingForm.deductions / Paycheck.wageFrequency
        adjustedWage = max(0.00, adjustedWage)
        
        // calculate the tentative withholding amount based on tax bracket data
        let schedule: WithholdingTable.Schedule = paycheck.withholdingForm.multipleJobs ? .multipleJobs : .standard
        
        guard let table = withholdingTables[paycheck.payPeriod.year] else {
            throw Error.noTaxTable(paycheck.payPeriod.year)
        }
        
        let brackets = table.taxBrackets[schedule]?[paycheck.withholdingForm.maritalStatus]
        
        guard let bracket = brackets?.last(where: { adjustedWage >= $0.atLeast }) else {
            throw Error.noTaxBracket(adjustedWage)
        }
        
        var federalWithholding = bracket.tentativeAmount + (adjustedWage - bracket.atLeast) * bracket.rate
        
        // account for tax credits
        var dependentCredits = Decimal(paycheck.withholdingForm.childDependents) * table.taxCredits.child
        dependentCredits += Decimal(paycheck.withholdingForm.otherDependents) * table.taxCredits.otherDependent
        federalWithholding -= dependentCredits / Paycheck.wageFrequency
        federalWithholding = max(0.00, federalWithholding)
        
        // calculate final withholding
        federalWithholding += paycheck.withholdingForm.extraWithholding
        federalWithholding.round(.toNearestOrAwayFromZero, digits: 2)
        
        // calculate FICA taxes
        let socialSecurity = (ficaWages * table.ficaRates.socialSecurity).rounded(.toNearestOrAwayFromZero, digits: 2)
        let medicare = (ficaWages * table.ficaRates.medicare).rounded(.toNearestOrAwayFromZero, digits: 2)
        
        // deductions and allotments
        let adjustments = paycheck.adjustments.sum(\.amount)
        
        // net pay
        var net = grossPay
        net -= traditionalTSP
        net -= rothTSP
        net -= federalWithholding
        net -= socialSecurity
        net -= medicare
        net -= adjustments

        return PaycheckResult(
            grossPay: grossPay,
            federalTaxableWages: federalTaxableWages,
            ficaWages: ficaWages,
            traditionalTSP: traditionalTSP,
            rothTSP: rothTSP,
            federalWithholding: federalWithholding,
            socialSecurity: socialSecurity,
            medicare: medicare,
            adjustments: adjustments,
            netPay: net
        )
    }
    
    func tspContribution(_ paycheck: Paycheck, type: Paycheck.TSPType) -> Decimal {
        let plan = switch type {
        case .traditional:
            paycheck.traditionalTSP
        case .roth:
            paycheck.rothTSP
        }
        
        let rate: (Paycheck.ThriftSavingsPlan, Paycheck.LESItem.Category) -> Decimal = { (plan, category) in
            switch category {
            case .specialPay:
                plan.specialPayRate
            case .incentivePay:
                plan.incentivePayRate
            case .bonusPay:
                plan.bonusPayRate
            default:
                Decimal.zero
            }
        }
        
        var contribution = paycheck.basicPay * plan.basicPayRate
        contribution += paycheck.entitlements.reduce(0.00) { sum, entitlement in
            sum + entitlement.amount * rate(plan, entitlement.category)
        }
        
        return contribution.rounded(.toNearestOrAwayFromZero, digits: 2)
    }
}


// MARK: - Pay System Error

extension PaySystem {
    enum Error: LocalizedError {
        case noTaxTable(Int)
        case noTaxBracket(Decimal)
        
        var errorDescription: String? {
            switch self {
            case .noTaxTable(let year):
                "Tax data unavailable for \(year.formatted(.number.grouping(.never)))."
            case .noTaxBracket(let income):
                "No tax bracket for \(income.formatted(.currency(code: "USD")))."
            }
        }
    }
}
