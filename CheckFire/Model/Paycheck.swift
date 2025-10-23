import Foundation
import SwiftData

@Model
final class Paycheck: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var payGrade = PayGrade.e1
    var yearsOfService = YearsOfService.lessThanOrEqual2
    var basicPay = BasicPayTables.shared.basicPay(
        for: Calendar.current.component(.year, from: .now),
        as: .e1,
        with: .lessThanOrEqual2
    ) ?? 0.00
    var bas = BASTables.shared.bas(
        for: Calendar.current.component(.year, from: .now),
        as: .e1
    ) ?? 0.00
    var vhaZIP = ""
    var bah: Decimal = 0.00
    
    @Relationship(deleteRule: .cascade, inverse: \LESItem.paycheck) var lesItems: [LESItem]? = []
    
    init(
        name: String,
        date: Date,
        payGrade: PayGrade,
        yearsOfService: YearsOfService,
        lesItems: [LESItem]? = nil,
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.payGrade = payGrade
        self.yearsOfService = yearsOfService
        let year = Calendar.current.component(.year, from: date)
        self.basicPay = BasicPayTables.shared.basicPay(
            for: year,
            as: payGrade,
            with: yearsOfService
        ) ?? 0.00
        self.bas = BASTables.shared.bas(for: year, as: payGrade) ?? 0.00
        self.vhaZIP = ""
        self.bah = 0.00
        
        self.lesItems = lesItems
    }
    
    convenience init() {
        self.init(
            name: "New Paycheck",
            date: .now,
            payGrade: .e1,
            yearsOfService: .lessThanOrEqual2
        )
    }
    
    var year: Int { Calendar.current.component(.year, from: date) }
    
    static let example: Paycheck = {
        let paycheck = Paycheck(
            name: "Example",
            date: DateComponents(calendar: .current, year: 2025, month: 2, day: 28).date!,
            payGrade: .o5,
            yearsOfService: .over20
        )
        paycheck.vhaZIP = "02842"
        paycheck.bah = 4485.00
        return paycheck        
    }()
}
