import Foundation

/// Creates a Decimal value from a String representing USD. Prevents numeric literal floating point errors.
/// - Parameter value: String representation of dollar amount.
/// - Returns: Decimal representation of dollar amount.
func money(_ value: String) -> Decimal {
    Decimal(string: value)!
}
