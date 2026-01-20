import Foundation

extension Decimal {
    /// A rule for rounding a decimal number.
    enum DecimalRoundingRule: Copyable, Equatable, Hashable, Sendable {
        case down
        case up
        case toNearestOrAwayFromZero
        case toNearestOrEven
        
        var mode: Decimal.RoundingMode {
            switch self {
            case .down:
                .down
            case .up:
                .up
            case .toNearestOrAwayFromZero:
                .plain
            case .toNearestOrEven:
                .bankers
            }
        }
    }
    
    /// Returns a value rounded using the specified rounding rule to the given number of fractional digits.
    /// - Parameters:
    ///   - rule: The rounding rule to apply.
    ///   - digits: The number of digits to keep after the decimal point.
    /// - Returns: A new value rounded according to `rule` and `digits`.
    func rounded(_ rule: DecimalRoundingRule, digits: Int) -> Decimal {
        var number = self
        var result: Decimal = 0
        NSDecimalRound(&result, &number, digits, rule.mode)
        
        return result
    }
    
    func rounded() -> Decimal {
        rounded(.toNearestOrAwayFromZero, digits: 0)
    }
    
    /// Rounds using the specified rounding rule to the given number of fractional digits.
    /// - Parameter rule: The rounding rule to apply.
    mutating func round(_ rule: DecimalRoundingRule, digits: Int) {
        self = rounded(rule, digits: digits)
    }
    
    mutating func round() {
        self = rounded(.toNearestOrAwayFromZero, digits: 0)
    }
}
