import Foundation
import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var paychecks: [Paycheck]
    @State private var showDeleteAlert = false
    
    private let contactURL = URL(string: "mailto:labs@thefoxrun.net")!
    private let supportURL = URL(string: "https://labs.thefoxrun.net/checkfire/")!
    private let privacyURL = URL(string: "https://labs.thefoxrun.net/checkfire/privacy.html")!
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        DocumentationView()
                    } label: {
                        Label("Official Documentation", systemImage: "book.pages")
                    }
                }
                
                Section("Support and Legal") {
                    Label("Version \(Bundle.main.versionString)", systemImage: "tag")
                    Link(destination: contactURL) { Label("Contact", systemImage: "envelope") }
                    Link(destination: supportURL) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    
                    Link(destination: privacyURL) { Label("Privacy Policy", systemImage: "lock") }
                    NavigationLink {
                        LicenseView()
                    } label: {
                        Label("License", systemImage: "text.page")
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
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
    
    Button("Show Sheet") { showSheet = true }
        .sheet(isPresented: $showSheet) { SettingsView() }
        .modelContainer(PreviewController.container)
}

