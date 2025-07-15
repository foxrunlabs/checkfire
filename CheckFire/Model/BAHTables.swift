import Foundation

final class BAHTables {
    private let mhaTables: [MHATable] = Bundle.main.decode(from: "mha_tables.json")
    private let bahTables: [BAHTable] = Bundle.main.decode(from: "bah_tables.json")
    
    var years: [Int] {
        bahTables.map { $0.year }
    }
    
    /// Private initializaer for singleton object.
    private init() {}
    
    private func mhaName(for year: Int, zipcode: String) -> String? {
        let mhaTable = mhaTables.first { $0.year == year }
        let mha = mhaTable?.mhas.first { $0.zipcode == zipcode }
        return mha?.name
    }
    
    func mha(for year: Int, in zipcode: String) -> String? {
        guard let mhaName = mhaName(for: year, zipcode: zipcode) else { return nil }
        let bahTable = bahTables.first { $0.year == year }
        let bahData = bahTable?.mhas.first { $0.mha == mhaName }
        return bahData?.description
    }
    
    func bah(
        for year: Int,
        in zipcode: String,
        as payGrade: PayGrade,
        withDependents: Bool
    ) -> Decimal? {
        guard let mhaName = mhaName(for: year, zipcode: zipcode) else { return nil }
        let bahTable = bahTables.first { $0.year == year }
        let bahData = bahTable?.mhas.first { $0.mha == mhaName }
        return withDependents ? bahData?.withDependents[payGrade] : bahData?.withoutDependents[payGrade]
    }
    
    static let shared = BAHTables()
}
