import SwiftData
import SwiftUI

@main
struct CheckFireApp: App {
    private let withholdingTables = WithholdingTableRepository(from: "withholding_tables.json")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(withholdingTables)
        .modelContainer(for: Paycheck.self)
    }
}
