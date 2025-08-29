import Foundation

extension SortOrder: @retroactive RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8) else { return nil }
        guard let sortOrder = try? JSONDecoder().decode(SortOrder.self, from: data) else { return nil }
        self = sortOrder
    }
    
    public var rawValue: RawValue {
        guard let data = try? JSONEncoder().encode(self) else { return "" }
        guard let result = String(data: data, encoding: .utf8) else { return "" }
        return result
    }
}
