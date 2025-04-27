import Foundation

struct FederalWithholdingData: Codable, Equatable {
    var maritalStatus: MaritalStatus
    var multipleJobs: Bool
    
    var childDependents: Int
    var otherDependents: Int
    
    var otherIncome: Decimal
    var deductions: Decimal
    var extraWithholding: Decimal
    
    /// Create myPay data.
    /// - Parameters:
    ///   - maritalStatus: Marital status for federal tax filing.
    ///   - multipleJobs: Multiple jobs checkbox from W-4.
    ///   - childDependents: Number of child dependents under 17.
    ///   - otherDependents: Number of other dependents over 17 and over.
    ///   - otherIncome: Other yearly income in dollars and not from jobs.
    ///   - deductions: Deductions in dollars, not including the standard deduction.
    ///   - extraWithholding: Extra withholding per month in dollars.
    init(
        maritalStatus: MaritalStatus = .single,
        multipleJobs: Bool = false,
        childDependents: Int = 0,
        otherDependents: Int = 0,
        otherIncome: Decimal = 0.00,
        deductions: Decimal = 0.00,
        extraWithholding: Decimal = 0.00
    ) {
        self.maritalStatus = maritalStatus
        self.multipleJobs = multipleJobs
        self.childDependents = childDependents
        self.otherDependents = otherDependents
        self.otherIncome = otherIncome
        self.deductions = deductions
        self.extraWithholding = extraWithholding
    }
    
    static let example = FederalWithholdingData(
        maritalStatus: .married,
        multipleJobs: true,
        childDependents: 2,
        otherDependents: 0,
        otherIncome: 0.00,
        deductions: 0.00,
        extraWithholding: 0.00
    )
}
