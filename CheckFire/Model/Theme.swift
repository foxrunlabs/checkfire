import Foundation

enum Theme: String, CaseIterable, CustomStringConvertible, Identifiable {
    case system
    case usaf
    case usa
    case uscg
    case usmc
    case usn
    case ussf
    
    // MARK: - Identifiable
    var id: Self { self }
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .system:
            "System"
        case .usaf:
            "U.S. Air Force"
        case .usa:
            "U.S. Army"
        case .uscg:
            "U.S. Coast Guard"
        case .usmc:
            "U.S. Marine Corps"
        case .usn:
            "U.S. Navy"
        case .ussf:
            "U.S. Space Force"
        }
    }
}
