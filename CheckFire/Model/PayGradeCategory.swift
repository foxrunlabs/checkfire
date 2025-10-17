import Foundation


enum PayGradeCategory: String, CaseIterable, CustomStringConvertible, Identifiable {
    case all
    case officers
    case priorEnlisted
    case warrants
    case enlisted
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .all: "All"
        case .officers: "Commissioned Officers"
        case .priorEnlisted: "Prior Enlisted Officers"
        case .warrants: "Warrant Officers"
        case .enlisted: "Enlisted Members"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
