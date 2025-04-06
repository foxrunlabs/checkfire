import Foundation

struct MyPayData: Codable {
    var maritalStatus: MaritalStatus = .single
    var multipleJobs = false
    
    var childDependents: Int = 0
    var otherDependents: Int = 0
    
    var otherIncome: Decimal = 0.00
    var deductions: Decimal = 0.00
    var extraWithholding: Decimal = 0.00
    
    var traditionalTspPercentage = 0.00
    var rothTspPercentage = 0.00
    
    static let example = MyPayData(
        maritalStatus: .married,
        multipleJobs: true,
        childDependents: 2,
        otherDependents: 0,
        otherIncome: 0.00,
        deductions: 0.00,
        extraWithholding: 0.00,
        traditionalTspPercentage: 0.11,
        rothTspPercentage: 0.00
    )
}
