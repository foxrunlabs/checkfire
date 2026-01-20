import Foundation

enum MaritalStatus:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    CustomStringConvertible,
    Identifiable
{
    case single
    case marriedFilingJointly
    case marriedFilingSeparately
    case headOfHousehold
    
    // MARK: - CustomStringConvertible
    var description: String {
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



