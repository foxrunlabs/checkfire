import Foundation

struct BasicPayTable: Decodable {
    typealias PaySchedule = [YearsOfService: Decimal?]
    
    let year: Int
    let schedule: [PayGrade: PaySchedule]
}
