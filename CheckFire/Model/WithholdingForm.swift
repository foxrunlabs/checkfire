import Foundation
import SwiftData

@Model
final class WithholdingForm: Identifiable {
    var id = UUID()
    var name = ""
    var date = Calendar.current.lastDateOfMonth(from: .now) ?? .now
    
    var maritalStatus = MaritalStatus.single
    var multipleJobs = false
    var childDependents = 0
    var otherDependents = 0
    
    var otherIncome: Decimal = 0.00
    var deductions: Decimal = 0.00
    var extraWithholding: Decimal = 0.00
    
    init(
        name: String,
        date: Date,
        maritalStatus: MaritalStatus,
        multipleJobs: Bool,
        childDependents: Int,
        otherDependents: Int,
        otherIncome: Decimal,
        deductions: Decimal,
        extraWithholding: Decimal,
    ) {
        self.id = UUID()
        self.name = name
        self.date = Calendar.current.lastDateOfMonth(from: date) ?? date
        
        self.maritalStatus = maritalStatus
        self.multipleJobs = multipleJobs
        self.childDependents = childDependents
        self.otherDependents = otherDependents
        
        self.otherIncome = otherIncome
        self.deductions = deductions
        self.extraWithholding = extraWithholding
    }
    
    convenience init() {
        self.init(
            name: "New Withholding",
            date: .now,
            maritalStatus: .single,
            multipleJobs: false,
            childDependents: 0,
            otherDependents: 0,
            otherIncome: 0.00,
            deductions: 0.00,
            extraWithholding: 0.00
        )
    }
    
    static let example = WithholdingForm(
        name: "Example",
        date: DateComponents(calendar: .current, year: 2025, month: 1, day: 1).date!,
        maritalStatus: .married,
        multipleJobs: true,
        childDependents: 2,
        otherDependents: 0,
        otherIncome: 0.00,
        deductions: 0.00,
        extraWithholding: 0.00
    )
}
