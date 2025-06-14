import Foundation
import SwiftData

@Model
final class ThriftSavingsPlan: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var traditionalBasePay: Decimal = 0.00
    var traditionalSpecialPay: Decimal = 0.00
    var traditionalIncentivePay: Decimal = 0.00
    var traditionalBonusPay: Decimal = 0.00
    
    var rothBasePay: Decimal = 0.00
    var rothSpecialPay: Decimal = 0.00
    var rothIncentivePay: Decimal = 0.00
    var rothBonusPay: Decimal = 0.00
    
    @Relationship(deleteRule: .noAction, inverse: \Paycheck.thriftSavingsPlan)
    var paychecks: [Paycheck]? = []
    
    init(
        name: String,
        date: Date,
        traditionalBasePay: Decimal,
        traditionalSpecialPay: Decimal,
        traditionalIncentivePay: Decimal,
        traditionalBonusPay: Decimal,
        rothBasePay: Decimal,
        rothSpecialPay: Decimal,
        rothIncentivePay: Decimal,
        rothBonusPay: Decimal,
        paychecks: [Paycheck]? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.traditionalBasePay = traditionalBasePay
        self.traditionalSpecialPay = traditionalSpecialPay
        self.traditionalIncentivePay = traditionalIncentivePay
        self.traditionalBonusPay = traditionalBonusPay
        
        self.rothBasePay = rothBasePay
        self.rothSpecialPay = rothSpecialPay
        self.rothIncentivePay = rothIncentivePay
        self.rothBonusPay = rothBonusPay
        
        self.paychecks = paychecks
    }
    
    static let example = ThriftSavingsPlan(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 1, day: 1).date!,
        traditionalBasePay: 0.11,
        traditionalSpecialPay: 0.00,
        traditionalIncentivePay: 0.00,
        traditionalBonusPay: 0.00,
        rothBasePay: 0.00,
        rothSpecialPay: 0.00,
        rothIncentivePay: 0.00,
        rothBonusPay: 0.00
    )
}
