import Foundation
import SwiftData

@Model
final class ThriftSavingsPlan: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var traditionalBasePay: Double = 0.00
    var traditionalSpecialPay: Double = 0.00
    var traditionalIncentivePay: Double = 0.00
    var traditionalBonusPay: Double = 0.00
    
    var rothBasePay: Double = 0.00
    var rothSpecialPay: Double = 0.00
    var rothIncentivePay: Double = 0.00
    var rothBonusPay: Double = 0.00
    
    init(
        name: String,
        date: Date,
        traditionalBasePay: Double,
        traditionalSpecialPay: Double,
        traditionalIncentivePay: Double,
        traditionalBonusPay: Double,
        rothBasePay: Double,
        rothSpecialPay: Double,
        rothIncentivePay: Double,
        rothBonusPay: Double,
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
