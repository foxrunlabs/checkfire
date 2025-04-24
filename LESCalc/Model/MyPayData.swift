import Foundation

struct MyPayData: Codable, Equatable {
    var maritalStatus: MaritalStatus
    var multipleJobs: Bool
    
    var childDependents: Int
    var otherDependents: Int
    
    var otherIncome: Decimal
    var deductions: Decimal
    var extraWithholding: Decimal
    
    /// Create myPay data as filing single, one job, all other values zeroed.
    init() {
        self.maritalStatus = .single
        self.multipleJobs = false
        self.childDependents = 0
        self.otherDependents = 0
        self.otherIncome = 0.00
        self.deductions = 0.00
        self.extraWithholding = 0.00
    }
    
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
        maritalStatus: MaritalStatus,
        multipleJobs: Bool,
        childDependents: Int,
        otherDependents: Int,
        otherIncome: Decimal,
        deductions: Decimal,
        extraWithholding: Decimal
    ) {
        self.maritalStatus = maritalStatus
        self.multipleJobs = multipleJobs
        self.childDependents = childDependents
        self.otherDependents = otherDependents
        self.otherIncome = otherIncome
        self.deductions = deductions
        self.extraWithholding = extraWithholding
    }
    
    static let example = MyPayData(
        maritalStatus: .married,
        multipleJobs: true,
        childDependents: 2,
        otherDependents: 0,
        otherIncome: 0.00,
        deductions: 0.00,
        extraWithholding: 0.00
    )
}
