import Foundation

extension Decimal {
    /// A rule for rounding a decimal number.
    enum DecimalRoundingRule: Copyable, Equatable, Hashable, Sendable {
        case down
        case up
        case toNearestOrAwayFromZero
        case toNearestOrEven
    }
    
    /// Returns this value rounded to an integral value using the specified rounding rule.
    /// - Parameter rule: The rounding rule to use.
    /// - Returns: The integral value found by rounding using rule.
    func rounded(_ rule: DecimalRoundingRule, digits: Int) -> Self {
        var number = self
        var result: Decimal = 0
        
        let roundingMode = switch rule {
        case .down:
            NSDecimalNumber.RoundingMode.down
        case .up:
            NSDecimalNumber.RoundingMode.up
        case .toNearestOrAwayFromZero:
            NSDecimalNumber.RoundingMode.plain
        case .toNearestOrEven:
            NSDecimalNumber.RoundingMode.bankers
        }
        
        NSDecimalRound(&result, &number, digits, roundingMode)
        
        return result
    }
    
    func rounded() -> Self {
        rounded(.toNearestOrAwayFromZero, digits: 0)
    }
    
    /// Rounds the value to an integral value using the specified rounding rule.
    /// - Parameter rule: The rounding rule to use.
    mutating func round(_ rule: DecimalRoundingRule, digits: Int) {
        self = rounded(rule, digits: digits)
    }
    
    mutating func round() {
        self = rounded(.toNearestOrAwayFromZero, digits: 0)
    }
}
