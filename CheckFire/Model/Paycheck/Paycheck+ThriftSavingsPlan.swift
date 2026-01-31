import Foundation

extension Paycheck {
    struct ThriftSavingsPlan: Codable {
        var basicPayRate: Decimal = 0.00 {
            didSet {
                if basicPayRate.isZero {
                    specialPayRate = 0.00
                    incentivePayRate = 0.00
                    bonusPayRate = 0.00
                }
            }
        }
        
        var specialPayRate: Decimal = 0.00
        var incentivePayRate: Decimal = 0.00
        var bonusPayRate: Decimal = 0.00
    }
}
