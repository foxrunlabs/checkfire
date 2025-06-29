import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    @Bindable private var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showPayTablesSheet = false
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
    }
    
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") {
                PaycheckDetailView(for: paycheck)
            }
            
            Tab("Net Pay", systemImage: "plus.forwardslash.minus") {
                NetPayView(for: paycheck)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Base Pay Tables", systemImage: "tablecells") {
                        showPayTablesSheet.toggle()
                    }
                    .tint(.accentColor)
                    
                    Button("Delete Paycheck", systemImage: "trash", role: .destructive) {
                        deletePaycheck()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showPayTablesSheet) {
            BasePayTablesView(
                year: Calendar.current.component(.year, from: paycheck.date),
                payGrade: paycheck.payGrade
            )
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
