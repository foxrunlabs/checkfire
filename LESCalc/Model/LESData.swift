import Foundation

struct LESData: Codable {
    var basePay: Decimal = 0.00
    var specialPays: Decimal = 0.00
    var allowances: Decimal = 0.00
    var otherDeductions: Decimal = 0.00
    var allotments: Decimal = 0.00
    
    var grossPay: Decimal { basePay + specialPays + allowances }
    
    static let example = LESData(
        basePay: 11592.30,
        specialPays: 840.00,
        allowances: 4805.78,
        otherDeductions: 41.00,
        allotments: 29.98
    )
}
