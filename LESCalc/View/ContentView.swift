import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ContentUnavailableView(
                "Select a paycheck from the sidebar",
                systemImage: "sidebar.left"
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewController.container)
}
