import Foundation

enum PayGrade:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    CustomStringConvertible,
    Identifiable
{
    case o10, o9, o8, o7, o6, o5, o4, o3, o2, o1
    case o3E, o2E, o1E
    case w5, w4, w3, w2, w1
    case o0
    case e9, e8, e7, e6, e5, e4, e3, e2, e1
    
    var description: String {
        switch self {
        case .o10: "O-10"
        case .o9: "O-9"
        case .o8: "O-8"
        case .o7: "O-7"
        case .o6: "O-6"
        case .o5: "O-5"
        case .o4: "O-4"
        case .o3: "O-3"
        case .o2: "O-2"
        case .o1: "O-1"
        case .o3E: "O-3E"
        case .o2E: "O-2E"
        case .o1E: "O-1E"
        case .w5: "W-5"
        case .w4: "W-4"
        case .w3: "W-3"
        case .w2: "W-2"
        case .w1: "W-1"
        case .o0: "MIDN/OC"
        case .e9: "E-9"
        case .e8: "E-8"
        case .e7: "E-7"
        case .e6: "E-6"
        case .e5: "E-5"
        case .e4: "E-4"
        case .e3: "E-3"
        case .e2: "E-2"
        case .e1: "E-1"
        }
    }
    
    var id: Self { self }
}
