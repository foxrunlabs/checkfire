import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedNavigation: SidebarNavigation?
    
    @Query private var paychecks: [Paycheck]
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showSettingsSheet = false
    
    var body: some View {
        List(selection: $selectedNavigation) {
            Section("Pay Data") {
                ForEach(SidebarNavigation.payDataCases) { navigationItem in
                    ListRow(
                        navigation: navigationItem,
                        badge: badgeCount(for: navigationItem)
                    )
                    .tag(navigationItem)
                }
            }
            
            Section("Tables") {
                ForEach(SidebarNavigation.tableCases) { navigationItem in
                    ListRow(navigation: navigationItem, badge: badgeCount(for: navigationItem))
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
    
    private func badgeCount(for navigation: SidebarNavigation) -> Int {
        switch navigation {
        case .paychecks: paychecks.count
        case .withholdingForms: withholdingForms.count
        case .thriftSavingsPlans: thriftSavingsPlans.count
        default: 0
        }
    }
}

fileprivate struct ListRow: View {
    let navigation: SidebarNavigation
    let badge: Int
    
    var body: some View {
        NavigationLink(value: navigation) {
            Label {
                Text(String(describing: navigation))
                    .badge(badge)
            } icon: {
                Image(systemName: navigation.icon)
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
