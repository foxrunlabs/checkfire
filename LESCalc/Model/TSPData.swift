import Foundation

struct TSPData: Codable {
    var traditionalTspPercentage = 0.00
    var rothTspPercentage = 0.00
    
    static let example = TSPData(traditionalTspPercentage: 0.11, rothTspPercentage: 0.00)
}
