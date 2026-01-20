import Foundation

extension Calendar {
    /// Returns the last date of the month containing the given date.
    /// - Parameter date: A date within the desired month.
    /// - Returns: A `Date` representing the last day of that month, or `nil` if the date cannot be computed.
    func lastDateOfMonth(from date: Date) -> Date? {
        guard let dayRange = range(of: .day, in: .month, for: date) else { return nil }
        var components = dateComponents([.year, .month], from: date)
        components.day = dayRange.count
        return self.date(from: components)
    }
}
