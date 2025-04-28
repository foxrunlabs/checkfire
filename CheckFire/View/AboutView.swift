import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let contactURL = URL(string: "mailto:kj6msg@icloud.com")!
    private let sourceDocs: [SourceDocumentation] = Bundle.main.decode(from: "source_documentation.json")
    
    private var version: String {
        let number = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return number + " (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Copyright © 2025 Ryan Clarke")
                    Text("Version " + version)
                    LinkItem("Contact", systemImage: "envelope", url: contactURL)
                }
                
                Section("Official Documentation") {
                    ForEach(sourceDocs) { doc in
                        LinkItem(doc.name, systemImage: "network", url: doc.url)
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
    
    private struct LinkItem: View {
        let label: String
        let systemImage: String
        let url: URL
        
        init(_ label: String, systemImage: String, url: URL) {
            self.label = label
            self.systemImage = systemImage
            self.url = url
        }
        
        var body: some View {
            Link(destination: url) {
                Label(label, systemImage: systemImage)
                    .tint(.primary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showAbout = true
    
    Button("Show About") { showAbout.toggle() }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
}
