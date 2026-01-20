import SwiftData

@MainActor
class PreviewController {
    static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Paycheck.self, configurations: config)
            container.mainContext.insert(Paycheck.example)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
