import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        return short + " (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Version") {
                        Text(version)
                    }
                    
                    Link(destination: URL(string: "mailto:kj6msg@icloud.com")!) {
                        Label("Contact", systemImage: "envelope")
                    }
                }
                
                Section("Official Documentation") {
                    ForEach(documentation) { doc in
                        Link(doc.name, destination: doc.url)
                    }
                }
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Documentation Data
    private struct Documentation: Identifiable {
        let id = UUID()
        let name: String
        let url: URL
        
        init(name: String, urlString: String) {
            self.name = name
            self.url = URL(string: urlString)!
        }
    }
    
    private let documentation = [
        Documentation(
            name: "DoD FMR Volume 7A",
            urlString: "https://comptroller.defense.gov/Portals/45/documents/fmr/Volume_07a.pdf"
        ),
        Documentation(
            name: "IRS Publication 15-T",
            urlString: "https://www.irs.gov/forms-pubs/about-publication-15-t"
        ),
        Documentation(
            name: "IRS Publication 501",
            urlString: "https://www.irs.gov/publications/p501"
        ),
        Documentation(
            name: "IRS Publication 505",
            urlString: "https://www.irs.gov/publications/p505"
        ),
        Documentation(
            name: "IRS Schedule 8812 (Form 1040)",
            urlString: "https://www.irs.gov/pub/irs-pdf/f1040s8.pdf"
        )
    ]
}

#Preview {
    AboutView()
}
