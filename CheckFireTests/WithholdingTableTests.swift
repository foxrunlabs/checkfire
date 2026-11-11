import Foundation
import Testing

@testable import CheckFire

@Suite("Withholding Table Tests") struct WithholdingTableTests {
    static let paySystem = PaySystem(from: "withholding_tables.json")
    
    @Test("Bracket Thresholds", arguments: [
        (input: money("1249.00"), expected: money("0.00")),
        (input: money("1250.00"), expected: money("0.00")),
        (input: money("1251.00"), expected: money("0.10")),
        (input: money("2243.00"), expected: money("99.30")),
        (input: money("2244.00"), expected: money("99.40")),
        (input: money("2245.00"), expected: money("99.52")),
        (input: money("5289.00"), expected: money("464.80")),
        (input: money("5290.00"), expected: money("464.92")),
        (input: money("5291.00"), expected: money("465.14")),
        (input: money("9862.00"), expected: money("1470.76")),
        (input: money("9863.00"), expected: money("1470.98")),
        (input: money("9864.00"), expected: money("1471.22")),
        (input: money("17691.00"), expected: money("3349.70")),
        (input: money("17692.00"), expected: money("3349.94")),
        (input: money("17693.00"), expected: money("3350.26")),
        (input: money("22126.00"), expected: money("4768.82")),
        (input: money("22127.00"), expected: money("4769.14")),
        (input: money("22128.00"), expected: money("4769.49")),
        (input: money("53445.00"), expected: money("15730.44")),
        (input: money("53446.00"), expected: money("15730.79")),
        (input: money("53447.00"), expected: money("15731.16")),
    ])
    func bracketThresholds(input: Decimal, expected: Decimal) throws {
        let paycheck = Paycheck(year: 2025, basicPay: input)
        let result = try WithholdingTableTests.paySystem.calculate(paycheck)
        
        #expect(result.federalWithholding == expected)
    }
    
    @Suite("Withholding Form Tests") struct WithholdingFormTests {
        @Suite("Error Tests") struct ErrorTests {
            @Test("Invalid Tax Year") func invalidTaxYear() {
                let paycheck = Paycheck(year: 1981)
                
                let error = #expect(throws: PaySystem.Error.self) {
                    try paySystem.calculate(paycheck)
                }
                
                guard case .noTaxTable(_) = error else {
                    Issue.record("Expected noTaxTable error")
                    return
                }
            }
            
            @Test("Invalid Tax Bracket") func invalidTaxBracket() {
                let paycheck = Paycheck(basicPay: money("-1000.00"))
                
                // The pay system should never throw `invalidTaxBracket` with the way it's written.
                #expect(throws: Never.self) {
                    try paySystem.calculate(paycheck)
                }
            }
        }
        
        @Test("Tax Years", arguments: [
            (year: 2023, expected: money("1573.04")),
            (year: 2024, expected: money("1528.16")),
            (year: 2025, expected: money("1503.86")),
        ])
        func taxYears(year: Int, expected: Decimal) throws {
            let paycheck = Paycheck(year: year, basicPay: money("10000.00"))
            let result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == expected)
        }
        
        @Test("Filing Status") func filingStatus() throws {
            // Single
            let paycheck = Paycheck(year: 2025, basicPay: money("10000.00"))
            var result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("1503.86"))
            
            // Married filing jointly
            paycheck.withholdingForm.maritalStatus = .marriedFilingJointly
            result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("860.24"))
            
            // Married filing separately
            paycheck.withholdingForm.maritalStatus = .marriedFilingSeparately
            result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("1503.86"))
            
            // Head of household
            paycheck.withholdingForm.maritalStatus = .headOfHousehold
            result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("1218.76"))
        }
        
        @Test("Multiple Jobs") func multipleJobs() throws {
            // One job
            let paycheck = Paycheck(year: 2025, basicPay: money("10000.00"))
            var result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("1503.86"))
            
            // Multiple jobs
            paycheck.withholdingForm.multipleJobs = true
            result = try WithholdingTableTests.paySystem.calculate(paycheck)
            
            #expect(result.federalWithholding == money("2044.26"))
        }
        
        @Suite("Withholding Adjustment Tests") struct WithholdingAdjustmentTests {
            @Test("Other Income") func otherIncome() throws {
                let paycheck = Paycheck(
                    year: 2025,
                    basicPay: money("10000.00"),
                    withholdingForm: .init(otherIncome: money("1200.00"))
                )
                
                let result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("1527.86"))
            }
            
            @Test("Deductions") func deductions() throws {
                let paycheck = Paycheck(
                    year: 2025,
                    basicPay: money("10000.00"),
                    withholdingForm: .init(deductions: money("1200.00"))
                )
                
                let result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("1479.86"))
            }
            
            @Test("Tax Credits") func taxCredits() throws {
                // Child Dependents
                let paycheck = Paycheck(
                    year: 2025,
                    basicPay: money("10000.00"),
                    withholdingForm: .init(childDependents: 1)
                )
                
                var result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("1337.19"))
                
                // Other dependents
                paycheck.withholdingForm.childDependents = 0
                paycheck.withholdingForm.otherDependents = 1
                
                result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("1462.19"))
                
                // Child and other dependents
                paycheck.withholdingForm.childDependents = 1
                
                result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("1295.53"))
            }
            
            @Test("Withholding Floor") func withholdingFloor() throws {
                // Verify withholding floor of $0.00
                let paycheck = Paycheck(
                    year: 2025,
                    basicPay: money("2500.00"),
                    withholdingForm: .init(childDependents: 1)
                )
                
                var result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == 0.00)
                
                // Verify extra withholding added after credits
                paycheck.withholdingForm.extraWithholding = money("100.00")
                
                result = try WithholdingTableTests.paySystem.calculate(paycheck)
                #expect(result.federalWithholding == money("100.00"))
            }
        }
    }
}
