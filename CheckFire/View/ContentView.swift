import SwiftData
import SwiftUI

struct ContentView: View {
    @Binding private var theme: Theme
    private let themeManager: ThemeManager
    @State private var selectedPaycheck: Paycheck?
    
    init(theme: Binding<Theme>) {
        self._theme = theme
        self.themeManager = .init(theme: theme.wrappedValue)
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(theme: $theme, selection: $selectedPaycheck)
        } detail: {
            if let selectedPaycheck {
                PaycheckView(paycheck: selectedPaycheck)
            } else {
                ContentUnavailableView(
                    "No Paycheck Selected",
                    systemImage: "sidebar.left",
                    description: Text("Please select a paycheck.")
                )
                .background(themeManager.systemBackground)
                .navigationTitle("CheckFire")
                .navigationBarTitleDisplayMode(.inline)
                .checkFireNavigationBarStyle(themeManager: themeManager)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .tint(themeManager.tint)
        .environment(themeManager)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var theme = Theme.system
    
    ContentView(theme: $theme)
        .modelContainer(PreviewController.container)
}
