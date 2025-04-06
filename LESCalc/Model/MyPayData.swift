import Foundation

struct MyPayData {
    var maritalStatus: MaritalStatus = .single
    var multipleJobs = false
    var childDependents: Int = 0
    var otherDependents: Int = 0
    var otherIncome: Decimal = 0.00
    var deductions: Decimal = 0.00
    var extraWithholding: Decimal = 0.00
    var tspPercentage = 0.00
}
