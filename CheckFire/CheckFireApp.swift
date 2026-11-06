import SwiftData
import SwiftUI

@main
struct CheckFireApp: App {
    private let paySystem = PaySystem(from: "withholding_tables.json")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(paySystem)
        .modelContainer(for: Paycheck.self)
    }
}
