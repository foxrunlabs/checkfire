import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
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
                Group {
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
                .checkFireListRowStyle(themeManager: themeManager)
            }
            .navigationTitle("About")
            .checkFireListBackground(themeManager: themeManager)
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
    @Previewable @State var showAbout = true
    
    Button("Show About") {
        showAbout.toggle()
    }
    .sheet(isPresented: $showAbout) {
        AboutView()
    }
    .environment(ThemeManager(theme: .system))
}
