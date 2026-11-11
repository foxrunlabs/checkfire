import SwiftData

enum CheckFireMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [CheckFireSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
