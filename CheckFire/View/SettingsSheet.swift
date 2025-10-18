import SwiftData
import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showDeleteAlert = false
    
    private let contactURL = URL(string: "mailto:foxrunlabs@icloud.com")!
    private let sourceDocs: [SourceDocumentation] = Bundle.main.decode(from: "source_documentation.json")
    
    private var version: String {
        let number = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return number + " (\(build))"
    }
    
    private var isDeleteDisabled: Bool {
        paychecks.isEmpty && withholdingForms.isEmpty && thriftSavingsPlans.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Copyright © 2025 Ryan Clarke")
                    
                    Text("Version " + version)
                    
                    Link(destination: contactURL) {
                        Label("Contact", systemImage: "envelope")
                    }
                }
                
                Section("Official Documentation") {
                    ForEach(sourceDocs) { doc in
                        Link(destination: doc.url) {
                            Label(doc.name, systemImage: "network")
                        }
                    }
                }
                
                Section {
                    Button("Delete All Data", systemImage: "trash", role: .destructive) {
                        showDeleteAlert.toggle()
                    }
                    .disabled(isDeleteDisabled)
                    .confirmationDialog("Delete All Day?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            deleteAllData()
                        }
                        
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure?")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                    .modifier(DoneButtonStyle())
                }
            }
        }
    }
    
    private func deleteAllData() {
        paychecks.forEach { modelContext.delete($0) }
        withholdingForms.forEach { modelContext.delete($0) }
        thriftSavingsPlans.forEach { modelContext.delete($0) }
    }
    
    private struct DoneButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 26, *) {
                content
                    .labelStyle(.automatic)
            } else {
                content
                    .labelStyle(.titleOnly)
            }
        }
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

