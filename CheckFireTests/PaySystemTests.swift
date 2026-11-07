import Foundation
import Observation
import SwiftUI
import Testing
@testable import CheckFire

func money(_ value: String) -> Decimal { Decimal(string: value, locale: Locale(identifier: "en_US_POSIX"))! }
func paycheck(_ basic: Decimal = 2000, year: Int = 2025) -> Paycheck {
    Paycheck(date: Calendar.current.date(from: DateComponents(year: year, month: 6, day: 15))!, basicPay: basic)
}

// Deliberately simple monthly brackets: 0 below 1,000; 10% to 2,000;
// then 100 + 20% of the excess. Multiple-jobs schedule doubles the rate.
func fixture(year: Int = 2025) -> WithholdingTable {
    let standard: [WithholdingTable.WithholdingData] = [
        .init(atLeast: 0, tentativeAmount: 0, rate: 0),
        .init(atLeast: 1000, tentativeAmount: 0, rate: money("0.1")),
        .init(atLeast: 2000, tentativeAmount: 100, rate: money("0.2"))
    ]
    let multiple = standard.map { WithholdingTable.WithholdingData(atLeast: $0.atLeast, tentativeAmount: $0.tentativeAmount * 2, rate: $0.rate * 2) }
    return WithholdingTable(year: year, taxCredits: .init(child: 1200, otherDependent: 600),
        ficaRates: .init(medicare: money("0.0145"), socialSecurity: money("0.062")),
        taxBrackets: [.standard: Dictionary(uniqueKeysWithValues: MaritalStatus.allCases.map { ($0, standard) }),
                      .multipleJobs: Dictionary(uniqueKeysWithValues: MaritalStatus.allCases.map { ($0, multiple) })])
}

@Suite @MainActor
struct PaySystemTests {
    let system = PaySystem(tables: [fixture()])

    @Test func zeroPay() throws {
        let r = try system.calculate(paycheck(0))
        #expect(r.grossPay == 0 && r.netPay == 0 && r.totalTax == 0 && r.totalTSP == 0)
    }

    @Test func completePaycheck() throws {
        let p = paycheck(4000)
        p.lesItems = [.init("Allowance", amount: 1000, category: .allowance),
                      .init("Special", amount: 300, category: .specialPay),
                      .init("Incentive", amount: 200, category: .incentivePay),
                      .init("Bonus", amount: 500, category: .bonusPay),
                      .init("Deduction", amount: 40, category: .deduction),
                      .init("Allotment", amount: 60, category: .allotment)]
        p.traditionalTSP = .init(basicPayRate: money("0.1"), specialPayRate: money("0.2"), incentivePayRate: money("0.3"), bonusPayRate: money("0.4"))
        p.rothTSP = .init(basicPayRate: money("0.05"), specialPayRate: money("0.1"), incentivePayRate: money("0.2"), bonusPayRate: money("0.3"))
        let r = try system.calculate(p)
        #expect(r.grossPay == 6000)
        #expect(r.traditionalTSP == 720 && r.rothTSP == 420 && r.totalTSP == 1140)
        #expect(r.federalTaxableWages == 4280)
        #expect(r.ficaWages == 4000) // Intentional model: basic pay alone is subject to FICA.
        #expect(r.socialSecurity == 248 && r.medicare == 58)
        #expect(r.federalWithholding == 556 && r.totalTax == 862)
        #expect(r.adjustments == 100 && r.netPay == 3898)
    }

    @Test(arguments: Paycheck.LESItem.Category.allCases)
    func ficaUsesBasicPayOnly(category: Paycheck.LESItem.Category) throws {
        let p = paycheck()
        let before = try system.calculate(p)
        p.lesItems = [.init("Added item", amount: 10000, category: category)]
        p.traditionalTSP.basicPayRate = money("0.25")
        p.rothTSP.basicPayRate = money("0.1")
        let after = try system.calculate(p)
        #expect(after.ficaWages == 2000)
        #expect(after.socialSecurity == before.socialSecurity && after.medicare == before.medicare)
    }

    @Test(arguments: [("999.99", "0"), ("1000", "0"), ("1000.01", "0"),
                       ("1999.99", "100"), ("2000", "100"), ("2000.01", "100"), ("2500", "200")],
          MaritalStatus.allCases)
    func brackets(example: (String, String), status: MaritalStatus) throws {
        let p = paycheck(money(example.0))
        p.withholdingForm.maritalStatus = status
        #expect(try system.calculate(p).federalWithholding == money(example.1))
        p.withholdingForm.multipleJobs = true
        #expect(try system.calculate(p).federalWithholding == money(example.1) * 2)
    }

    @Test func w4AdjustmentsCreditsAndExtraWithholding() throws {
        let p = paycheck(2500)
        p.withholdingForm.multipleJobs = true
        p.withholdingForm.otherIncome = 1200 // +100 monthly
        p.withholdingForm.deductions = 600 // -50 monthly
        p.withholdingForm.childDependents = 1 // -100 monthly
        p.withholdingForm.otherDependents = 1 // -50 monthly
        p.withholdingForm.extraWithholding = money("12.345")
        #expect(try system.calculate(p).federalWithholding == money("282.35"))
        p.withholdingForm.deductions = 120000
        #expect(try system.calculate(p).federalWithholding == money("12.35"))
        p.withholdingForm.extraWithholding = 0
        #expect(try system.calculate(p).federalWithholding == 0)
    }

    @Test func traditionalReducesFederalWagesRothDoesNot() throws {
        let p = paycheck(3000)
        p.traditionalTSP.basicPayRate = money("0.1")
        p.rothTSP.basicPayRate = money("0.2")
        let r = try system.calculate(p)
        #expect(r.federalTaxableWages == 2700 && r.federalWithholding == 240)
        #expect(r.ficaWages == 3000 && r.totalTSP == 900)
    }

    @Test func roundingOccursAfterSummingTSP() throws {
        let p = paycheck(money("0.05"))
        p.lesItems = [.init("Special", amount: money("0.05"), category: .specialPay)]
        p.traditionalTSP = .init(basicPayRate: money("0.1"), specialPayRate: money("0.1"))
        #expect(system.tspContribution(p, type: .traditional) == money("0.01"))
        p.lesItems = []
        #expect(system.tspContribution(p, type: .traditional) == money("0.01"))
        #expect(try system.calculate(paycheck(1)).medicare == money("0.01"))
        #expect(try system.calculate(paycheck(1)).socialSecurity == money("0.06"))
        #expect(try system.calculate(paycheck(money("1000.05"))).federalWithholding == money("0.01"))
    }

    @Test func recalculatesWithoutMutatingInputs() throws {
        let p = paycheck()
        let first = try system.calculate(p)
        p.basicPay = 3000
        let second = try system.calculate(p)
        #expect(first.grossPay == 2000 && second.grossPay == 3000)
        #expect(p.basicPay == 3000 && p.lesItems.isEmpty)
        p.lesItems = [.init("Large deduction", amount: 10000, category: .deduction)]
        #expect(try system.calculate(p).netPay < 0)
    }

    @Test func missingTableAndBracketErrors() throws {
        do {
            _ = try system.calculate(paycheck(year: 1999))
            Issue.record("Expected missing table")
        } catch PaySystemError.noTaxTable(let year) { #expect(year == 1999) }
        let t = fixture()
        let missing = PaySystem(tables: [.init(year: 2025, taxCredits: t.taxCredits, ficaRates: t.ficaRates, taxBrackets: [:])])
        do {
            _ = try missing.calculate(paycheck())
            Issue.record("Expected missing bracket")
        } catch PaySystemError.noTaxBracket(let wages) { #expect(wages == 2000) }
        #expect(PaySystemError.noTaxTable(1999).errorDescription == "Missing tax table")
        #expect(PaySystemError.noTaxBracket(1).failureReason != nil)
    }

    @Test func observationAndEnvironmentContract() {
        func requiresObservable<T: Observable>(_ value: T) {}
        requiresObservable(system)
        _ = Text("Test").environment(system)
    }

    @Test func taxYearRangeUsesExtremes() {
        #expect(PaySystem(tables: [fixture(year: 2026), fixture(year: 2024)]).taxYears == 2024...2026)
    }

    // Fixed regression values from the repository's monthly tables, not a tax-law certification.
    @Test(arguments: [
        (2023, ["455.08", "286.36", "455.08", "365.86", "786.48", "455.08", "786.48", "650.08"]),
        (2024, ["434.64", "269.36", "434.64", "353.42", "764.12", "434.64", "764.12", "622.46"]),
        (2025, ["430.12", "260.24", "430.12", "346.66", "751.94", "430.12", "751.94", "609.28"])
    ])
    func bundledWithholdingRegression(example: (Int, [String])) throws {
        let bundled = PaySystem(from: "withholding_tables.json")
        let statuses: [MaritalStatus] = [.single, .marriedFilingJointly, .marriedFilingSeparately, .headOfHousehold]
        for (scheduleIndex, multiple) in [false, true].enumerated() {
            for (statusIndex, status) in statuses.enumerated() {
                let p = paycheck(5000, year: example.0)
                p.withholdingForm.maritalStatus = status
                p.withholdingForm.multipleJobs = multiple
                let r = try bundled.calculate(p)
                #expect(r.federalWithholding == money(example.1[scheduleIndex * 4 + statusIndex]))
                #expect(r.socialSecurity == 310 && r.medicare == money("72.50"))
            }
        }
    }

    @Test func creditsClampBeforeExtraWithholding() throws {
        let p = paycheck(2500)
        p.withholdingForm.childDependents = 10
        p.withholdingForm.extraWithholding = 25
        #expect(try system.calculate(p).federalWithholding == 25)
    }

    @Test func missingBracketForWageBelowFirstThreshold() throws {
        let t = fixture()
        let system = PaySystem(tables: [.init(year: 2025, taxCredits: t.taxCredits, ficaRates: t.ficaRates,
            taxBrackets: [.standard: [.single: [.init(atLeast: 3000, tentativeAmount: 0, rate: 0)]]])])
        do {
            _ = try system.calculate(paycheck())
            Issue.record("Expected missing bracket below the first threshold")
        } catch PaySystemError.noTaxBracket(let wage) { #expect(wage == 2000) }
    }

    @Test func bundledTablesLoadAndCalculate() throws {
        let bundled = PaySystem(from: "withholding_tables.json")
        for year in bundled.taxYears {
            for status in MaritalStatus.allCases {
                for multiple in [false, true] {
                    let p = paycheck(5000, year: year)
                    p.withholdingForm.maritalStatus = status
                    p.withholdingForm.multipleJobs = multiple
                    let r = try bundled.calculate(p)
                    #expect(r.federalWithholding >= 0 && r.netPay <= r.grossPay)
                }
            }
        }
    }
}
