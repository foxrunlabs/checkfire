import Foundation

struct TSPData: Codable, Equatable {
    var traditionalTspPercentage: Double
    var rothTspPercentage: Double
    
    /// Create TSP data with percentages zeroed.
    init() {
        self.traditionalTspPercentage = 0.00
        self.rothTspPercentage = 0.00
    }
    
    /// Create TSP data.
    /// - Parameters:
    ///   - traditionalTspPercentage: Percentage of base pay allocated to traditional TSP.
    ///   - rothTspPercentage: Percentage of base pay allocated to Roth TSP.
    init(traditionalTspPercentage: Double, rothTspPercentage: Double) {
        self.traditionalTspPercentage = traditionalTspPercentage
        self.rothTspPercentage = rothTspPercentage
    }
    
    static let example = TSPData(traditionalTspPercentage: 0.11, rothTspPercentage: 0.00)
}
