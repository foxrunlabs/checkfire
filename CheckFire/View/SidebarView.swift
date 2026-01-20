import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedNavigation: SidebarNavigation?
    
    @Query private var paychecks: [Paycheck]
    @State private var showSettingsSheet = false
    
    // MARK: - Body
    var body: some View {
        List(selection: $selectedNavigation) {
            Section {
                ForEach(SidebarNavigation.allCases) { navigationItem in
                    ListRow(
                        navigation: navigationItem,
                        badge: badgeCount(for: navigationItem)
                    )
                    .tag(navigationItem)
                }
            }
        }
        .navigationTitle("CheckFire")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gear") {
                    showSettingsSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheet()
        }
    }
    
    // MARK: - Methods
    private func badgeCount(for navigation: SidebarNavigation) -> Int {
        switch navigation {
        case .paychecks: paychecks.count
        }
    }
}


// MARK: - List Row
extension SidebarView {
    private struct ListRow: View {
        let navigation: SidebarNavigation
        let badge: Int
        
        // MARK: - Body
        var body: some View {
            NavigationLink(value: navigation) {
                Label {
                    Text(String(describing: navigation))
                        .badge(badge)
                } icon: {
                    Image(systemName: navigation.icon)
                        .foregroundStyle(navigation.color)
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var selectedNavigation: SidebarNavigation?
    
    NavigationStack {
        SidebarView(selectedNavigation: $selectedNavigation)
    }
    .modelContainer(PreviewController.container)
}
