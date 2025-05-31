import Foundation

struct FederalWithholdingData: Codable, Equatable {
    var maritalStatus = MaritalStatus.single
    var multipleJobs = false
    var childDependents = 0
    var otherDependents = 0
    var otherIncome: Decimal = 0.00
    var deductions: Decimal = 0.00
    var extraWithholding: Decimal = 0.00
    
    static let example = FederalWithholdingData(
        maritalStatus: .married,
        multipleJobs: true,
        childDependents: 2
    )
}
