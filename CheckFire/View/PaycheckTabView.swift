import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") {
                PaycheckDetailView(paycheck: paycheck)
            }
            
            Tab("Net Pay", systemImage: "plus.forwardslash.minus") {
                NetPayView(paycheck: paycheck)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Delete Paycheck", systemImage: "trash", role: .destructive) {
                    deletePaycheck()
                    dismiss()
                }
            }
        }
    }
    
    private func deletePaycheck() {
        modelContext.delete(paycheck)
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        PaycheckTabView(paycheck: paycheck)
    }
    .modelContainer(PreviewController.container)
}
