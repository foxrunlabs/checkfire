extension Paycheck {
    enum TSPType: CaseIterable, Identifiable {
        case traditional
        case roth
        
        // MARK: - Computed Properties
        
        var displayName: String {
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
