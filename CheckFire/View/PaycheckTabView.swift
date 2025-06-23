import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    @Bindable private var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
    }
    
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") {
                PaycheckDetailView(for: paycheck)
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
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                // dismiss the keyboard
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
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
        PaycheckTabView(for: paycheck)
    }
    .modelContainer(PreviewController.container)
}
