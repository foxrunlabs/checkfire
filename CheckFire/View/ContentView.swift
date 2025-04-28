import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedPaycheck: Paycheck?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedPaycheck)
        } detail: {
            if let selectedPaycheck {
                PaycheckView(paycheck: selectedPaycheck)
            } else {
                ContentUnavailableView(
                    "Select a paycheck from the sidebar",
                    systemImage: "sidebar.left"
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(PreviewController.container)
}
