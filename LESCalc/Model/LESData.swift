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
    
    /// Creates empty LES data with the date set to the current date and base pay set to $0.00.
    init() {
        var components = Calendar.current.dateComponents([.year, .month], from: .now)
        components.day = 1
        self.date = components.date ?? .now
        self.basePay = LESItem(name: "Base Pay", amount: 0.00)
        self.specialPays = []
        self.allowances = []
        self.deductions = []
        self.allotments = []
    }
    
    /// Creates LES data.
    /// - Parameters:
    ///   - date: LES date.
    ///   - basePay: Base pay in dollars.
    ///   - specialPays: An array of special pays.
    ///   - allowances: An array of allowances.
    ///   - deductions: An array of deductions, not including federal tax, FICA tax, or TSP.
    ///   - allotments: An array of allotments.
    init(
        date: Date,
        basePay: Decimal,
        specialPays: [LESItem],
        allowances: [LESItem],
        deductions: [LESItem],
        allotments: [LESItem]
    ) {
        var components = Calendar.current.dateComponents([.year, .month], from: date)
        components.day = 1
        self.date = components.date ?? date
        self.basePay = LESItem(name: "Base Pay", amount: basePay)
        self.specialPays = specialPays
        self.allowances = allowances
        self.deductions = deductions
        self.allotments = allotments
    }
    
    /// Create LES data from existing LES data.
    /// - Parameter lesData: LES data to copy.
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
