import Foundation

struct TSPData: Codable, Equatable {
    var traditionalTspPercentage: Double
    var rothTspPercentage: Double
    
    /// Create TSP data.
    /// - Parameters:
    ///   - traditionalTspPercentage: Percentage of base pay allocated to traditional TSP.
    ///   - rothTspPercentage: Percentage of base pay allocated to Roth TSP.
    init(traditionalTspPercentage: Double = 0.00, rothTspPercentage: Double = 0.00) {
        self.traditionalTspPercentage = traditionalTspPercentage
        self.rothTspPercentage = rothTspPercentage
    }
    
    static let example = TSPData(traditionalTspPercentage: 0.11, rothTspPercentage: 0.00)
}
