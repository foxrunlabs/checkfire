import Foundation

extension Calendar {
    /// Returns the last date of the month using a given date.
    /// - Parameter date: Used as reference for the desired month.
    /// - Returns: A new `Date` representing the last date of the monht, or `nil` if unable to compute.
    func lastDateOfMonth(from date: Date) -> Date? {
        guard let dayRange = self.range(of: .day, in: .month, for: date) else { return nil }
        var components = self.dateComponents([.calendar, .year, .month, .day], from: date)
        components.day = dayRange.upperBound - 1
        return components.date
    }
}
