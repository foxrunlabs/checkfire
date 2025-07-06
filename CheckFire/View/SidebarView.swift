import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedNavigation: SidebarNavigation?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showPayTablesSheet = false
    @State private var showBASTablesSheet = false
    @State private var showAboutSheet = false
    
    @State private var showDeleteAlert = false
    
    var isDeleteDisabled: Bool {
        paychecks.isEmpty && withholdingForms.isEmpty && thriftSavingsPlans.isEmpty
    }
    
    var body: some View {
        List(selection: $selectedNavigation) {
            Section("Pay Data") {
                ForEach(SidebarNavigation.allCases) { navigationItem in
                    PayDataListRow(
                        navigation: navigationItem,
                        badge: badgeCount(for: navigationItem)
                    )
                    .tag(navigationItem)
                }
            }
            
            Section("Tools") {
                Button("Base Pay Tables", systemImage: "tablecells") {
                    showPayTablesSheet.toggle()
                }
                
                Button("BAS Tables", systemImage: "fork.knife") {
                    showBASTablesSheet.toggle()
                }
            }
        }
        .navigationTitle("CheckFire")
        .toolbar {
            ToolbarItem {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("About CheckFire", systemImage: "info.circle") {
                        showAboutSheet.toggle()
                    }
                    
                    Button("Delete All Data", systemImage: "trash", role: .destructive) {
                        showDeleteAlert.toggle()
                    }
                    .disabled(isDeleteDisabled)
                }
            }
        }
        .sheet(isPresented: $showPayTablesSheet) {
            BasePayTablesView()
        }
        .sheet(isPresented: $showBASTablesSheet) {
            BASTablesView()
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .alert("Delete All Data", isPresented: $showDeleteAlert) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                Button("Delete") { deleteAllData() }
                    .keyboardShortcut(.defaultAction)

                Button("Cancel") { }
                    .keyboardShortcut(.cancelAction)
            } else {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { deleteAllData() }
            }
        } message: {
            Text("Are you sure?")
        }
    }
    
    private struct PayDataListRow: View {
        let navigation: SidebarNavigation
        let badge: Int
        
        private var icon: String {
            switch navigation {
            case .paychecks: "dollarsign"
            case .withholdingForms: "pencil.and.list.clipboard"
            case .thriftSavingsPlans: "dollarsign.bank.building"
            }
        }
        
        var body: some View {
            NavigationLink(value: navigation) {
                Label {
                    Text(String(describing: navigation))
                        .badge(badge)
                } icon: {
                    Image(systemName: icon)
                }
            }
        }
    }
    
    private func badgeCount(for navigation: SidebarNavigation) -> Int {
        switch navigation {
        case .paychecks: paychecks.count
        case .withholdingForms: withholdingForms.count
        case .thriftSavingsPlans: thriftSavingsPlans.count
        }
    }
    
    private func deleteAllData() {
        paychecks.forEach { modelContext.delete($0) }
        withholdingForms.forEach { modelContext.delete($0) }
        thriftSavingsPlans.forEach { modelContext.delete($0) }
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
