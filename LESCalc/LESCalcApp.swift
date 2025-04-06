import SwiftData
import SwiftUI

@main
struct LESCalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Paycheck.self)
    }
}
