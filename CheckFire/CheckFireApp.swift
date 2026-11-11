import SwiftData
import SwiftUI

@main
struct CheckFireApp: App {
    private let paySystem = PaySystem(from: "withholding_tables.json")
    
    private let container: ModelContainer = {
        let schema = Schema(versionedSchema: CheckFireSchemaV1.self)
        
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: CheckFireMigrationPlan.self,
                configurations: [ModelConfiguration(schema: schema)]
            )
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(paySystem)
        .modelContainer(container)
    }
}
