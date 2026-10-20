import Foundation

extension Paycheck {
    struct WithholdingForm: Codable {
        var maritalStatus: MaritalStatus = .single
        var multipleJobs = false
        var childDependents = 0
        var otherDependents = 0
        var otherIncome: Decimal = 0.00
        var deductions: Decimal = 0.00
        var extraWithholding: Decimal = 0.00
        
        // MARK: - Example
        
        static let example = WithholdingForm(
            maritalStatus: .marriedFilingJointly,
            multipleJobs: true,
            childDependents: 2
        )
    }
}
