import Foundation
import SwiftData

@Model
final class ThriftSavingsPlan: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var traditionalBasicPay: Decimal = 0.00
    var traditionalSpecialPay: Decimal = 0.00
    var traditionalIncentivePay: Decimal = 0.00
    var traditionalBonusPay: Decimal = 0.00
    
    var rothBasicPay: Decimal = 0.00
    var rothSpecialPay: Decimal = 0.00
    var rothIncentivePay: Decimal = 0.00
    var rothBonusPay: Decimal = 0.00
    
    init(
        name: String,
        date: Date,
        traditionalBasicPay: Decimal,
        traditionalSpecialPay: Decimal,
        traditionalIncentivePay: Decimal,
        traditionalBonusPay: Decimal,
        rothBasicPay: Decimal,
        rothSpecialPay: Decimal,
        rothIncentivePay: Decimal,
        rothBonusPay: Decimal,
        paychecks: [Paycheck]? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.traditionalBasicPay = traditionalBasicPay
        self.traditionalSpecialPay = traditionalSpecialPay
        self.traditionalIncentivePay = traditionalIncentivePay
        self.traditionalBonusPay = traditionalBonusPay
        
        self.rothBasicPay = rothBasicPay
        self.rothSpecialPay = rothSpecialPay
        self.rothIncentivePay = rothIncentivePay
        self.rothBonusPay = rothBonusPay
    }
    
    convenience init() {
        self.init(
            name: "New TSP",
            date: .now,
            traditionalBasicPay: 0.00,
            traditionalSpecialPay: 0.00,
            traditionalIncentivePay: 0.00,
            traditionalBonusPay: 0.00,
            rothBasicPay: 0.00,
            rothSpecialPay: 0.00,
            rothIncentivePay: 0.00,
            rothBonusPay: 0.00
        )
    }
    
    static let example = ThriftSavingsPlan(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 1, day: 31).date!,
        traditionalBasicPay: 0.11,
        traditionalSpecialPay: 0.00,
        traditionalIncentivePay: 0.00,
        traditionalBonusPay: 0.00,
        rothBasicPay: 0.00,
        rothSpecialPay: 0.00,
        rothIncentivePay: 0.00,
        rothBonusPay: 0.00
    )
}
