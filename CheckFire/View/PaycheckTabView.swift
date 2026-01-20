import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    @Bindable var paycheck: Paycheck
    @Binding var selection: DetailSelection?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    // MARK: - Body
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") { PaycheckDetailView(paycheck: paycheck) }
            Tab("Net Pay", systemImage: "plus.forwardslash.minus") { NetPayView(paycheck: paycheck) }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Copy", systemImage: "document.on.document") { copyPaycheck() }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deletePaycheck()
                    dismiss()
                }
            }
        }
    }
    
    
    // MARK: - Methods
    private func copyPaycheck() {
        let newPaycheck = Paycheck(paycheck)
        newPaycheck.name = paycheck.name + " (copy)"
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
    }
    
    private func deletePaycheck() {
        modelContext.delete(paycheck)
        selection = nil
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var selection: DetailSelection?
    
    NavigationStack {
        PaycheckTabView(paycheck: Paycheck.example, selection: $selection)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
