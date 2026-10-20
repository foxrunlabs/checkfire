import SwiftUI

struct DocumentationView: View {
    private let sourceDocs: [SourceDoc] = Bundle.main.decode(from: "source_documentation.json")
    
    // MARK: - Body
    
    var body: some View {
        List {
            ForEach(sourceDocs) { sourceDoc in
                Link(destination: sourceDoc.url) {
                    Label(sourceDoc.name, systemImage: "network")
                }
            }
        }
        .navigationTitle("Official Documentation")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        DocumentationView()
    }
}
