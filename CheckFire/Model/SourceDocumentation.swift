import Foundation

struct SourceDocumentation: Decodable, Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}
