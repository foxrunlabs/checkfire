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
                    Link(
                        "DoD FMR Volume 7A",
                        destination: URL(string: "https://comptroller.defense.gov/Portals/45/documents/fmr/Volume_07a.pdf")!
                    )
                    
                    Link(
                        "IRS Publication 15-T",
                        destination: URL(string: "https://www.irs.gov/forms-pubs/about-publication-15-t")!
                    )
                    
                    Link(
                        "IRS Publication 501",
                        destination: URL(string: "https://www.irs.gov/publications/p501")!
                    )
                    
                    Link(
                        "IRS Publication 505",
                        destination: URL(string: "https://www.irs.gov/publications/p505")!
                    )
                    
                    Link(
                        "IRS Schedule 8812 (Form 1040)",
                        destination: URL(string: "https://www.irs.gov/pub/irs-pdf/f1040s8.pdf")!
                    )
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
}

#Preview {
    AboutView()
}
