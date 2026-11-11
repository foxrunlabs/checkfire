import Foundation
import Testing

@testable import CheckFire

@Suite("TSP Tests") struct TSPTests {
    let paySystem = PaySystem(from: "withholding_tables.json")
    
    @Test("Traditional and Roth Contributions") func contributions() throws {
        let paycheck = Paycheck(
            year: 2025,
            basicPay: money("10000.00"),
            traditionalTSP: .init(basicPayRate: 0.10),
            rothTSP: .init(basicPayRate: 0.05)
        )
        
        var result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("1000.00"))
        #expect(result.rothTSP == money("500.00"))
        #expect(result.federalTaxableWages == money("9000.00"))
        #expect(result.netPay == money("6453.88"))
        
        // Verify changing one plan doesn't affect the other.
        paycheck.rothTSP.basicPayRate = 0.0
        result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("1000.00"))
        #expect(result.rothTSP == money("0.00"))
    }
    
    @Test("Additional LES Items") func additionalLESItems() throws {
        let paycheck = Paycheck(
            year: 2025,
            basicPay: money("10000.00"),
            lesItems: [
                Paycheck.LESItem("Special", amount: money("200.00"), category: .specialPay),
                Paycheck.LESItem("Incentive", amount: money("500.00"), category: .incentivePay),
                Paycheck.LESItem("Bonus", amount: money("300.00"), category: .bonusPay)
            ],
            traditionalTSP: .init(
                basicPayRate: 0.20,
                specialPayRate: 0.05,
                incentivePayRate: 0.1,
                bonusPayRate: 0.15
            )
        )
        
        var result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("2105.00"))
        
        // Verify multiple entitlements in multiple categories
        paycheck.lesItems.append(contentsOf: [
            Paycheck.LESItem("Special 2", amount: money("100.00"), category: .specialPay),
            Paycheck.LESItem("Incentive 2", amount: money("250.00"), category: .incentivePay),
            Paycheck.LESItem("Bonus 2", amount: money("150.00"), category: .bonusPay)
        ])
        
        result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("2157.50"))
        
        // Verify allowances, allotmens, and deductions are not factored into computation.
        paycheck.lesItems.append(contentsOf: [
            Paycheck.LESItem("Allowance", amount: money("1000.00"), category: .allowance),
            Paycheck.LESItem("Allotment", amount: money("50.00"), category: .allotment),
            Paycheck.LESItem("Deduction", amount: money("175.00"), category: .deduction)
        ])
        
        result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("2157.50"))
        
        // Verify setting basic pay rate to 0% resets other elections to 0%.
        paycheck.traditionalTSP.basicPayRate = 0.0
        result = try paySystem.calculate(paycheck)
        
        #expect(result.traditionalTSP == money("0.00"))
    }
}
