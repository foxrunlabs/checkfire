import SwiftData
import SwiftUI

struct PaycheckView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("LES", systemImage: "plus.forwardslash.minus") {
                LESDataView(paycheck: paycheck)
                    .toolbarBackgroundVisibility(.visible, for: .tabBar, .navigationBar)
            }
            
            Tab("Withholding", systemImage: "pencil.and.list.clipboard") {
                FederalWithholdingView(paycheck: paycheck)
                    .toolbarBackgroundVisibility(.visible, for: .tabBar, .navigationBar)
            }
            
            Tab("TSP", systemImage: "dollarsign.bank.building") {
                TSPDataView(paycheck: paycheck)
                    .toolbarBackgroundVisibility(.visible, for: .tabBar, .navigationBar)
            }
            
            Tab("Net Pay", systemImage: "dollarsign") {
                NetPayView(paycheck: paycheck)
                    .toolbarBackgroundVisibility(.visible, for: .tabBar, .navigationBar)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
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
    PaycheckView(paycheck: Paycheck.example)
}
