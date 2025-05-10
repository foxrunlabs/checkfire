import SwiftData
import SwiftUI

@main
struct LESCalcApp: App {
    @AppStorage("theme") private var theme: Theme = .system
    
    var body: some Scene {
        WindowGroup {
            ContentView(theme: $theme)
        }
        .modelContainer(for: Paycheck.self)
    }
}
