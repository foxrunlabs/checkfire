import Foundation

struct LESData: Codable, Equatable {
    var date: Date = .now
    var basePay: Decimal = 0.00
    var specialPays: [LESItem] = []
    var allowances: [LESItem] = []
    var deductions: [LESItem] = []
    var allotments: [LESItem] = []
    
    var grossPay: Decimal {
        basePay + specialPays.reduce(0.00) { $0 + $1.amount } + allowances.reduce(0.00) { $0 + $1.amount }
    }
    
    static let example = LESData(
        date: DateComponents(calendar: Calendar.current, year: 2025, month: 1, day: 1).date!,
        basePay: 11592.30,
        specialPays: [LESItem(name: "Fly Pay", amount: 840.00)],
        allowances: [
            LESItem(name: "BAH", amount: 4485.00),
            LESItem(name: "BAS", amount: 320.78)],
        deductions: [
            LESItem(name: "SGLI", amount: 31.00),
            LESItem(name: "SGLI Family/Spouse", amount: 10.00)],
        allotments: [LESItem(name: "Tricare Dental", amount: 29.98)]
    )
}
