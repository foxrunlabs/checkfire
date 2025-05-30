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
    case married
    case headOfHousehold
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .single:
            "Single"
        case .married:
            "Married"
        case .headOfHousehold:
            "Head of Household"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
