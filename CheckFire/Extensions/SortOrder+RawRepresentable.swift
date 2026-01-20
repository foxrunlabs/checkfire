import Foundation

extension SortOrder: @retroactive RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "forward": self = .forward
        case "reverse": self = .reverse
        default: return nil
        }
    }

    public var rawValue: RawValue {
        switch self {
        case .forward: "forward"
        case .reverse: "reverse"
        }
    }
}
