import SwiftUI

struct SidebarView: View {
    @Binding var selectedNavigation: SidebarNavigation?
    
    @State private var showSettingsSheet = false
    
    // MARK: - Body
    var body: some View {
        List(selection: $selectedNavigation) {
            Section {
                ForEach(SidebarNavigation.allCases) { navigationItem in
                    ListRow(navigation: navigationItem)
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
}


// MARK: - List Row
fileprivate struct ListRow: View {
    let navigation: SidebarNavigation
    
    // MARK: - Body
    var body: some View {
        NavigationLink(value: navigation) {
            Label {
                Text(String(describing: navigation))
            } icon: {
                Image(systemName: navigation.icon)
                    .foregroundStyle(navigation.color)
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
