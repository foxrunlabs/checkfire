enum Month: Int, CaseIterable, Codable, Comparable, Identifiable {
    case january = 1
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    // MARK: - Properties
    
    static let symbols = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]
    
    static let shortSymbols = symbols.map { String($0.prefix(3)) }
    
    // MARK: - Computed Properties
    
    var symbol: String { Self.symbols[rawValue - 1] }
    var shortSymbol: String { Self.shortSymbols[rawValue - 1] }
    
    // MARK: - Comparable
    
    static func <(lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    
    // MARK: - Identifiable
    
    var id: Self { self }
}
