import Foundation

enum YearsOfService:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    CustomStringConvertible,
    Identifiable
{
    case lessThan4Months
    case lessThanOrEqual2
    case over2
    case over3
    case over4
    case over6
    case over8
    case over10
    case over12
    case over14
    case over16
    case over18
    case over20
    case over22
    case over24
    case over26
    case over28
    case over30
    case over32
    case over34
    case over36
    case over38
    case over40
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .lessThan4Months: "< 4 Months"
        case .lessThanOrEqual2: "2 or Less"
        case .over2: "Over 2"
        case .over3: "Over 3"
        case .over4: "Over 4"
        case .over6: "Over 6"
        case .over8: "Over 8"
        case .over10: "Over 10"
        case .over12: "Over 12"
        case .over14: "Over 14"
        case .over16: "Over 16"
        case .over18: "Over 18"
        case .over20: "Over 20"
        case .over22: "Over 22"
        case .over24: "Over 24"
        case .over26: "Over 26"
        case .over28: "Over 28"
        case .over30: "Over 30"
        case .over32: "Over 32"
        case .over34: "Over 34"
        case .over36: "Over 36"
        case .over38: "Over 38"
        case .over40: "Over 40"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
