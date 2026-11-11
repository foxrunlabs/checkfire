import Foundation
import Testing

@testable import CheckFire

@Suite("Pay System Tests") struct PaySystemTests {
    let basicPay = money("11592.30")
    let paySystem = PaySystem(from: "withholding_tables.json")

    @Test("Zeroed Paycheck") func zeroedPaycheck() throws {
        let paycheck = Paycheck()
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.grossPay == 0.00)
        #expect(result.federalTaxableWages == 0.00)
        #expect(result.ficaWages == 0.00)
        #expect(result.traditionalTSP == 0.00)
        #expect(result.rothTSP == 0.00)
        #expect(result.federalWithholding == 0.00)
        #expect(result.socialSecurity == 0.00)
        #expect(result.medicare == 0.00)
        #expect(result.adjustments == 0.00)
        #expect(result.netPay == 0.00)
    }
    
    @Test("Basic Pay Only") func basicPayOnly() throws {
        let paycheck = Paycheck(year: 2025, basicPay: basicPay)
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.grossPay == basicPay)
        #expect(result.federalWithholding == money("1886.01"))
        #expect(result.socialSecurity == money("718.72"))
        #expect(result.medicare == money("168.09"))
        #expect(result.netPay == money("8819.48"))
    }
    
    @Test("LES Item Effects") func lesItemEffects() throws {
        let paycheck = Paycheck(
            year: 2025,
            basicPay: basicPay,
            lesItems: [
                Paycheck.LESItem("BAS", amount: money("320.78"), category: .allowance),
                Paycheck.LESItem("SRB", amount: money("10000.00"), category: .bonusPay),
                Paycheck.LESItem("Fly Pay", amount: money("840.00"), category: .incentivePay),
                Paycheck.LESItem("HFP", amount: money("225.00"), category: .specialPay),
                Paycheck.LESItem("SGLI", amount: money("31.00"), category: .deduction),
                Paycheck.LESItem("TRICARE Dental", amount: money("29.98"), category: .allotment)
            ]
        )
        
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.grossPay == money("22978.08"))
        #expect(result.federalTaxableWages == money("22657.30"))
        #expect(result.federalWithholding == money("4954.75"))
        #expect(result.ficaWages == basicPay)
        #expect(result.socialSecurity == money("718.72"))
        #expect(result.medicare == money("168.09"))
        #expect(result.adjustments == money("60.98"))
    }
    
    @Test("TSP Effects") func tspEffects() throws {
        let paycheck = Paycheck(
            year: 2025,
            basicPay: basicPay,
            lesItems: [
                Paycheck.LESItem("BAS", amount: money("320.78"), category: .allowance),
                Paycheck.LESItem("Fly Pay", amount: money("840.00"), category: .incentivePay),
                Paycheck.LESItem("SGLI", amount: money("31.00"), category: .deduction),
                Paycheck.LESItem("TRICARE Dental", amount: money("29.98"), category: .allotment)
            ],
            traditionalTSP: Paycheck.ThriftSavingsPlan(basicPayRate: 0.05),
            rothTSP: Paycheck.ThriftSavingsPlan(basicPayRate: 0.05)
        )
        
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.grossPay == money("12753.08"))
        #expect(result.traditionalTSP == money("579.62"))
        #expect(result.rothTSP == money("579.62"))
        #expect(result.federalTaxableWages == money("11852.68"))
        #expect(result.federalWithholding == money("1948.50"))
        #expect(result.ficaWages == basicPay)
        #expect(result.netPay == money("8697.55"))
    }
    
    @Test("Negative Wages") func negativeWages() throws {
        let paycheck = Paycheck(year: 2025, basicPay: money("-1000.00"))
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.federalWithholding == money("0.00"))
    }
    
    @Test("Negative Net Pay") func negativeNetPay() throws {
        let paycheck = Paycheck(
            year: 2025,
            basicPay: basicPay,
            lesItems: [
                Paycheck.LESItem("Big Deduction", amount: money("12000.00"), category: .deduction)
            ]
        )
        
        let result = try paySystem.calculate(paycheck)
        
        #expect(result.netPay == money("-3180.52"))
    }
    
    @Test("Recalculation") func recalculation() throws {
        let paycheck = Paycheck(year: 2025, basicPay: basicPay)
        var result = try paySystem.calculate(paycheck)
        
        paycheck.year = 2024
        paycheck.basicPay = money("11093.10")
        result = try paySystem.calculate(paycheck)
        
        #expect(result.grossPay == money("11093.10"))
        #expect(result.federalWithholding == money("1790.50"))
        #expect(result.socialSecurity == money("687.77"))
        #expect(result.medicare == money("160.85"))
        #expect(result.netPay == money("8453.98"))
    }
    
    @Test("Known Paycheck") func knownPaycheck() throws {
        let paycheck = Paycheck(
            name: "Example",
            year: 2025,
            monthValue: Month.february.rawValue,
            payGrade: .o5,
            yearsOfService: .over20,
            basicPay: basicPay,
            lesItems: [
                Paycheck.LESItem("BAS", amount: money("320.78"), category: .allowance),
                Paycheck.LESItem("BAH", amount: money("4485.00"), category: .allowance),
                Paycheck.LESItem("Fly Pay", amount: money("840.00"), category: .incentivePay),
                Paycheck.LESItem("SGLI", amount: money("31.00"), category: .deduction),
                Paycheck.LESItem("SGLI Family/Spouse", amount: money("10.00"), category: .deduction),
                Paycheck.LESItem("TRICARE Dental", amount: money("29.98"), category: .allotment),
            ],
            withholdingForm: .example,
            traditionalTSP: Paycheck.ThriftSavingsPlan(basicPayRate: 0.11),
            rothTSP: Paycheck.ThriftSavingsPlan()
        )
        
        let result = try paySystem.calculate(paycheck)
        
        let knownResult = PaySystem.PaycheckResult(
            grossPay: money("17238.08"),
            federalTaxableWages: money("11157.15"),
            ficaWages: basicPay,
            traditionalTSP: money("1275.15"),
            rothTSP: 0.00,
            federalWithholding: money("1448.24"),
            socialSecurity: money("718.72"),
            medicare: money("168.09"),
            adjustments: money("70.98"),
            netPay: money("13556.90")
        )
        
        #expect(result == knownResult)
    }
}
