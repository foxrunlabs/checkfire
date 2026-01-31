// MARK: - Pay Grade
extension Paycheck {
    enum PayGrade:
        String,
        CaseIterable,
        Codable,
        CustomStringConvertible,
        Identifiable
    {
        case o10 = "o10", o9 = "o9", o8 = "o8", o7 = "o7", o6 = "o6", o5 = "o5", o4 = "o4", o3 = "o3", o2 = "o2", o1 = "o1"
        case o3e = "o3e", o2e = "o2e", o1e = "o1e"
        case w5 = "w5", w4 = "w4", w3 = "w3", w2 = "w2", w1 = "w1"
        case e9 = "e9", e8 = "e8", e7 = "e7", e6 = "e6", e5 = "e5", e4 = "e4", e3 = "e3", e2 = "e2", e1 = "e1"
        
        // MARK: - Properties
        static let officers: [Self] = [.o10, .o9, .o8, .o7, .o6, .o5, .o4, .o3, .o2, .o1]
        static let priorEnlisted: [Self] = [.o3e, .o2e, .o1e]
        static let warrants: [Self] = [.w5, .w4, .w3, .w2, .w1]
        static let enlisted: [Self] = [.e9, .e8, .e7, .e6, .e5, .e4, .e3, .e2, .e1]
        var isEnlisted: Bool { Self.enlisted.contains(self) }
        
        // MARK: - CustomStringConvertible
        var description: String {
            switch self {
            case .o1e: return "O-1E"
            case .o2e: return "O-2E"
            case .o3e: return "O-3E"
            default:
                let letter = rawValue.prefix(1).uppercased()
                let number = rawValue.dropFirst()
                return "\(letter)-\(number)"
            }
        }

        // MARK: - Identifiable
        var id: Self { self }
    }
}
