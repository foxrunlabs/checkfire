import Foundation

enum MaritalStatus: String, CaseIterable, Codable, CodingKeyRepresentable, Identifiable {
    case single
    case marriedFilingJointly
    case marriedFilingSeparately
    case headOfHousehold
    
    // MARK: - Computed Properties
    
    var displayName: String {
        switch self {
        case .single:
            "Single"
        case .marriedFilingJointly:
            "Married Filing Jointly"
        case .marriedFilingSeparately:
            "Married Filing Separately"
        case .headOfHousehold:
            "Head of Household"
        }
    }

    // MARK: - Identifiable
    
    var id: Self { self }
}



