import Foundation

enum WithholdingSchedule: String, Decodable, CodingKeyRepresentable {
    case standard
    case multipleJobs
}
