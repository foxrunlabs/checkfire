import Foundation

struct PayTable: Decodable {
    typealias PaySchedule = [YearsOfService: Decimal?]
    
    let year: Int
    let schedule: [PayGrade: PaySchedule]
}
