import Foundation
import SwiftData
import SwiftUI

struct SettingsSheet: View {
    private let contactURL = URL(string: "mailto:foxrunlabs@icloud.com")!
    private let sourceDocs: [SourceDoc] = Bundle.main.decode(from: "source_documentation.json")
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @State private var showDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Copyright © 2025 Ryan Clarke")
                    Text("Version " + Bundle.main.versionString)
                    Link(destination: contactURL) { Label("Contact", systemImage: "envelope") }
                }
                
                Section("Official Documentation") {
                    ForEach(sourceDocs) { sourceDoc in
                        Link(destination: sourceDoc.url) {
                            Label(sourceDoc.name, systemImage: "network")
                        }
                    }
                }
                
                Section {
                    Button("Delete All Data", systemImage: "trash", role: .destructive) {
                        showDeleteAlert.toggle()
                    }
                    .confirmationDialog("Delete All Data?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) { deleteAllData() }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure?")
                    }
                    .disabled(paychecks.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                        .buttonStyle(.glassProminent)
                }
            }
        }
    }
    
    // MARK: - Methods
    private func deleteAllData() {
        paychecks.forEach { modelContext.delete($0) }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var showSheet = true
    
    Button("Show Sheet") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        SettingsSheet()
    }
    .modelContainer(PreviewController.container)
}

