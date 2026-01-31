extension Paycheck {
    enum TSPType: CaseIterable, CustomStringConvertible, Identifiable {
        case traditional
        case roth
        
        // MARK: - CustomStringConvertible {
        var description: String {
            switch self {
            case .traditional:
                "Traditional"
            case .roth:
                "Roth"
            }
        }
        
        // MARK: - Identifiable
        var id: Self { self }
    }
}
