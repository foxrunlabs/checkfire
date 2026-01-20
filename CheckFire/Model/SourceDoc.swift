import Foundation

struct SourceDoc: Decodable, Identifiable {
    let id: UUID = UUID()
    let name: String
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}
