import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let contactURL = URL(string: "mailto:kj6msg@icloud.com")!
    private let sourceDocs: [SourceDocumentation] = Bundle.main.decode(from: "source_documentation.json")
    
    private var version: String {
        let number = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return number + " (\(build))"
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
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showAboutSheet = true
    
    Button("Show About") {
        showAboutSheet.toggle()
    }
    .sheet(isPresented: $showAboutSheet) {
        AboutSheet()
    }
}
