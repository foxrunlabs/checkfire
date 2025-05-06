import Foundation

struct LESData: Codable, Equatable {
    var date: Date
    var basePay: LESItem
    var entitlements: [LESItem]
    var deductions: [LESItem]
    var allotments: [LESItem]
    
    var grossPay: Decimal {
        basePay.amount + entitlements.reduce(0.00) { $0 + $1.amount }
    }
    
    /// Creates LES data.
    /// - Parameters:
    ///   - date: LES date.
    ///   - basePay: Base pay in dollars.
    ///   - entitlements: An array of entitlements, not including base pay.
    ///   - deductions: An array of deductions, not including federal tax, FICA tax, or TSP.
    ///   - allotments: An array of allotments.
    init(
        date: Date = .now,
        basePay: Decimal = 0.00,
        entitlements: [LESItem] = [],
        deductions: [LESItem] = [],
        allotments: [LESItem] = []
    ) {
        // set date to 1st of passed month for consistency
        var components = Calendar.current.dateComponents([.calendar, .year, .month], from: date)
        components.day = 1
        self.date = components.date ?? date
        self.basePay = LESItem(name: "Base Pay", amount: basePay, itemType: .basePay)
        self.entitlements = entitlements
        self.deductions = deductions
        self.allotments = allotments
    }
    
    static let example = LESData(
        date: DateComponents(calendar: .current, year: 2025, month: 1, day: 1).date!,
        basePay: 11592.30,
        entitlements: [
            LESItem(name: "Fly Pay", amount: 840.00, itemType: .incentivePay),
            LESItem(name: "BAH", amount: 4485.00, itemType: .allowance),
            LESItem(name: "BAS", amount: 320.78, itemType: .allowance)],
        deductions: [
            LESItem(name: "SGLI", amount: 31.00, itemType: .deduction),
            LESItem(name: "SGLI Family/Spouse", amount: 10.00, itemType: .deduction)],
        allotments: [LESItem(name: "Tricare Dental", amount: 29.98, itemType: .allotment)]
    )
}
