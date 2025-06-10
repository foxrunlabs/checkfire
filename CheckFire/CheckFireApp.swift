import SwiftData
import SwiftUI

@main
struct CheckFireApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [Paycheck.self, WithholdingForm.self, ThriftSavingsPlan.self, LESItem.self]
        )
    }
}
