import Foundation

struct PayPeriod: Codable, Comparable {
    var year: Int
    var month: Month
    
    // MARK: - Initializer
    
    init(year: Int, month: Month) {
        precondition(year > 0)
        self.year = year
        self.month = month
    }
    
    // MARK: - Methods
    
    /// Returns a formatted string representation of the pay period with default width.
    ///
    /// - Returns: A string formatted pay period.
    func formatted() -> String { FormatStyle().format(self) }
    
    /// Returns a formatted string representation of the pay period with the specified month width.
    ///
    /// - Parameter width: The desired width for the month.
    /// - Returns: A string formatted pay period with the requested month width.
    func formatted(width: FormatStyle.Width) -> String {
        FormatStyle().width(width).format(self)
    }
    
    // MARK: - Comparable
    
    static func <(lhs: Self, rhs: Self) -> Bool { (lhs.year, lhs.month) < (rhs.year, rhs.month) }
    
    // MARK: - Format Style
}


extension PayPeriod {
    struct FormatStyle: Foundation.FormatStyle {
        typealias FormatInput = PayPeriod
        typealias FormatOutput = String
        
        enum Width: Codable {
            case abbreviated
            case wide
        }
        
        // MARK: - Properties
        
        private var width: Width = .wide
        
        // MARK: - Methods
        
        /// Formats the given `PayPeriod` into a string using the configured width.
        ///
        /// - Parameter value: The `PayPeriod` to format.
        /// - Returns: A string representing the formatted pay period.
        func format(_ value: FormatInput) -> FormatOutput {
            let month = (width == .abbreviated) ? value.month.shortSymbol : value.month.symbol
            return "\(month) \(value.year.formatted(.number.grouping(.never)))"
        }
        
        /// Returns a copy of this `FormatStyle` configured to use the specified month width.
        ///
        /// - Parameter w: The desired month width.
        /// - Returns: A new `FormatStyle` instance set to the specified month width.
        func width(_ w: Width) -> Self {
            var copy = self
            copy.width = w
            return copy
        }
    }
}
