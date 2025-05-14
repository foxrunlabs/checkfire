import SwiftData
import SwiftUI

struct PaycheckView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    var body: some View {
        TabView {
            Tab("LES", systemImage: "plus.forwardslash.minus") {
                LESDataView(paycheck: paycheck)
                    .checkFireTabStyle(themeManager: themeManager)
            }
            
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(paycheck: paycheck)
                    .checkFireTabStyle(themeManager: themeManager)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(paycheck: paycheck)
                    .checkFireTabStyle(themeManager: themeManager)
            }
            
            Tab("Net Pay", systemImage: "dollarsign") {
                NetPayView(paycheck: paycheck)
                    .checkFireTabStyle(themeManager: themeManager)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .checkFireNavigationBarStyle(themeManager: themeManager)
        .tint(themeManager.tabViewTint)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete Paycheck", systemImage: "trash", role: .destructive) {
                    deletePaycheck(paycheck)
                    dismiss()
                }
            }
        }
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        PaycheckView(paycheck: paycheck)
            .environment(ThemeManager(theme: .uscg))
    }
}
