import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var payGrade = PayGrade.e1
    var yearsOfService = YearsOfService.lessThanOrEqual2
    var basePay: Decimal = 0.00
    
    @Relationship(deleteRule: .cascade, inverse: \LESItem.paycheck) var lesItems: [LESItem]? = []
    
    init(
        name: String,
        date: Date,
        payGrade: PayGrade,
        yearsOfService: YearsOfService,
        basePay: Decimal,
        lesItems: [LESItem]? = nil,
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.payGrade = payGrade
        self.yearsOfService = yearsOfService
        self.basePay = basePay
        
        self.lesItems = lesItems
    }
    
    /// Creates a new paycheck from another paycheck.
    /// - Parameter paycheck: Paycheck to copy.
    convenience init(_ other: Paycheck) {
        self.init(
            name: other.name,
            date: other.date,
            payGrade: other.payGrade,
            yearsOfService: other.yearsOfService,
            basePay: other.basePay
        )
    }
    
    static let example = Paycheck(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 2, day: 28).date!,
        payGrade: .o5,
        yearsOfService: .over20,
        basePay: 11592.30
    )
}
