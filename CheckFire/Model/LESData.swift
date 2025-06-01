import Foundation

struct LESData: Codable, Equatable {
    var date = Date.now
    var payGrade = PayGrade.e1
    var yearsOfService = YearsOfService.lessThanOrEqual2
    var basePay = LESItem(name: "Base Pay", amount: 0.00, itemType: .basePay)
    var entitlements: [LESItem] = []
    var deductions: [LESItem] = []
    var allotments: [LESItem] = []
    
    var grossPay: Decimal {
        basePay.amount + entitlements.reduce(0.00) { $0 + $1.amount }
    }
    
    func entitlementPay(for entitlementType: LESItemType) -> Decimal {
        entitlements.filter({ $0.itemType == entitlementType }).reduce(0.00) { $0 + $1.amount }
    }
    
    static let example = LESData(
        date: DateComponents(calendar: .current, year: 2025, month: 1, day: 1).date!,
        payGrade: .o5,
        yearsOfService: .over20,
        basePay: LESItem(name: "Base Pay", amount: 11592.30, itemType: .basePay),
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
