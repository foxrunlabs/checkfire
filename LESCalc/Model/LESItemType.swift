import Foundation

enum LESItemType: String, CaseIterable, Codable, CustomStringConvertible, Identifiable {
    case specialPay
    case allowance
    case deduction
    case allotment
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .specialPay: "Special Pay"
        case .allowance: "Allowance"
        case .deduction: "Deduction"
        case .allotment: "Allotment"
        }
    }
}
