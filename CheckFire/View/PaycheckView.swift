import SwiftData
import SwiftUI

struct PaycheckView: View {
    @Binding var paycheck: Paycheck?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        if let paycheck {
            TabView {
                Tab("LES", systemImage: "plus.forwardslash.minus") {
                    LESDataView(paycheck: paycheck)
                        .checkFireTabViewStyle(themeManager: themeManager)
                        .tint(themeManager.tint)
                }
                
                Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                    FederalWithholdingView(paycheck: paycheck)
                        .checkFireTabViewStyle(themeManager: themeManager)
                        .tint(themeManager.tint)
                }
                
                Tab("TSP", systemImage: "dollarsign.bank.building") {
                    TSPDataView(paycheck: paycheck)
                        .checkFireTabViewStyle(themeManager: themeManager)
                        .tint(themeManager.tint)
                }
                
                Tab("Net Pay", systemImage: "dollarsign") {
                    NetPayView(paycheck: paycheck)
                        .checkFireTabViewStyle(themeManager: themeManager)
                        .tint(themeManager.tint)
                }
            }
            .navigationTitle(paycheck.name)
            .navigationBarTitleDisplayMode(.inline)
            .tint(themeManager.tabViewTint)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete Paycheck", systemImage: "trash", role: .destructive) {
                        deletePaycheck(paycheck)
                        dismiss()
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "Select a paycheck from the sidebar",
                systemImage: "sidebar.left"
            )
            .background(themeManager.systemBackground)
        }
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck: Paycheck? = Paycheck.example
    
    PaycheckView(paycheck: $paycheck)
        .environment(ThemeManager(theme: .system))
}
