import Foundation

struct LESData {
    var year: Int = TaxYears.shared.years.last!
    var basePay: Decimal = 0.00
    var specialPays: Decimal = 0.00
    var allowances: Decimal = 0.00
    var otherDeductions: Decimal = 0.00
    var allotments: Decimal = 0.00
    
    var grossPay: Decimal { basePay + specialPays + allowances }
    
    func tspContribution(using myPayData: MyPayData) -> Decimal {
        basePay * Decimal(myPayData.tspPercentage)
    }
    
    func wagePeriod(using myPayData: MyPayData) -> Decimal {
        basePay + specialPays - tspContribution(using: myPayData)
    }
    
    /// Calculate federal income tax withholding for a given Form W-4.
    /// - Parameter formW4: Form W-4 used to calculate taxes.
    /// - Returns: Federal income tax withholding.
    func federalTaxes(using myPayData: MyPayData) -> Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        let wage = wagePeriod(using: myPayData)
        return taxData.calculateWithholding(for: wage, using: myPayData)
    }
    
    /// Calculate Medicare tax withholding for a given Form W-4.
    /// - Parameter formW4: Form W-4 used to calculate Medicare tax.
    /// - Returns: Medicare tax withholding.
    func medicare(using myPayData: MyPayData) -> Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        return (basePay * taxData.medicareRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Calculate Social Security tax withholding for a given Form W-4.
    /// - Parameter formW4: Form W-4 used to calculate Social Security tax.
    /// - Returns: Social Security tax withholding.
    func socialSecurity(using myPayData: MyPayData) -> Decimal {
        guard let taxData = TaxYears.shared.taxData(for: year) else {
            fatalError("No tax data found for \(year.description)")
        }
        return (basePay * taxData.socialSecurityRate).rounded(.toNearestOrAwayFromZero, digits: 2)
    }
    
    /// Net monthly pay after taxes and other deductions.
    /// - Parameter formW4: FOrm W-4 used to calculate taxes.
    /// - Returns: Net monthly pay.
    func netPay(using myPayData: MyPayData) -> Decimal {
        var net = grossPay
        net -= tspContribution(using: myPayData) + otherDeductions + allotments
        net -= federalTaxes(using: myPayData)
        net -= medicare(using: myPayData) + socialSecurity(using: myPayData)
        return net
    }
    
    static let example = LESData(
        year: 2025,
        basePay: 11592.30,
        specialPays: 840.00,
        allowances: 4805.78,
        otherDeductions: 41.00,
        allotments: 29.98
    )
}
