import Foundation

struct LESData: Codable, Equatable {
    var date: Date
    var basePay: LESItem
    var allowances: [LESItem]
    var specialPays: [LESItem]
    var deductions: [LESItem]
    var allotments: [LESItem]
    
    var grossPay: Decimal {
        basePay.amount
            + specialPays.reduce(0.00) { $0 + $1.amount }
            + allowances.reduce(0.00) { $0 + $1.amount }
    }
    
    init(
        date: Date = .now,
        basePay: Decimal = 0.00,
        specialPays: [LESItem] = [],
        allowances: [LESItem] = [],
        deductions: [LESItem] = [],
        allotments: [LESItem] = []
    ) {
        self.date = date
        self.basePay = LESItem(name: "Base Pay", amount: basePay)
        self.specialPays = specialPays
        self.allowances = allowances
        self.deductions = deductions
        self.allotments = allotments
    }
    
    init(copyFrom lesData: LESData) {
        self.date = lesData.date
        self.basePay = LESItem(name: "Base Pay", amount: lesData.basePay.amount)
        self.specialPays = lesData.specialPays.map { LESItem(name: $0.name, amount: $0.amount) }
        self.allowances = lesData.allowances.map { LESItem(name: $0.name, amount: $0.amount) }
        self.deductions = lesData.deductions.map { LESItem(name: $0.name, amount: $0.amount) }
        self.allotments = lesData.allotments.map { LESItem(name: $0.name, amount: $0.amount) }
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
