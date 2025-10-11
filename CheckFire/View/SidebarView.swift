import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedNavigation: SidebarNavigation?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Query private var withholdingForms: [WithholdingForm]
    @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showBasicPayTablesSheet = false
    @State private var showBAHTablesSheet = false
    @State private var showBASTablesSheet = false
    @State private var showAboutSheet = false
    
    @State private var showDeleteAlert = false
    
    private var isDeleteDisabled: Bool {
        paychecks.isEmpty && withholdingForms.isEmpty && thriftSavingsPlans.isEmpty
    }
    
    private var menuIcon: String {
        if #available(iOS 26, *) {
            "ellipsis"
        } else {
            "ellipsis.circle"
        }
    }
    
    private var aboutIcon: String {
        if #available(iOS 26, *) {
            "info"
        } else {
            "info.circle"
        }
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
                Button("Basic Pay Tables", systemImage: "tablecells") {
                    showBasicPayTablesSheet.toggle()
                }
                
                Button("BAH Tables", systemImage: "house") {
                    showBAHTablesSheet.toggle()
                }
                
                Button("BAS Tables", systemImage: "fork.knife") {
                    showBASTablesSheet.toggle()
                }
            }
        }
        .navigationTitle("CheckFire")
        .toolbar {
            ToolbarItem {
                Menu("Options", systemImage: menuIcon) {
                    Button("About CheckFire", systemImage: aboutIcon) {
                        showAboutSheet.toggle()
                    }
                    
                    Button("Delete All Data", systemImage: "trash", role: .destructive) {
                        showDeleteAlert.toggle()
                    }
                    .disabled(isDeleteDisabled)
                }
            }
        }
        .sheet(isPresented: $showBasicPayTablesSheet) {
            BasicPayTablesSheet()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showBAHTablesSheet) {
            BAHTablesSheet()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showBASTablesSheet) {
            BASTablesSheet()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutSheet()
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
