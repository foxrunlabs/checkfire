import SwiftData
import SwiftUI

struct PaychecksListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    @State private var showAddPaycheckSheet = false
    
    var body: some View {
        Group {
            if paychecks.isEmpty {
                ContentUnavailableView(
                    "No Paychecks Found",
                    systemImage: "dollarsign",
                    description: Text("Please add a new paycheck.")
                )
            } else {
                List(selection: $selectedPayComponent) {
                    ForEach(paychecks) { paycheck in
                        PaycheckListRow(for: paycheck)
                            .tag(PayComponent.paycheck(paycheck))
                    }
                    .onDelete(perform: deletePaychecks)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Paychecks")
        .toolbar {
            ToolbarItem {
                Button("Add Paycheck", systemImage: "plus") {
                    showAddPaycheckSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddPaycheckSheet) {
            AddPaycheckSheet(selectedPayComponent: $selectedPayComponent)
                .presentationDetents([.medium])
        }
    }
    
    private struct PaycheckListRow: View {
        private let paycheck: Paycheck
        
        init(for paycheck: Paycheck) {
            self.paycheck = paycheck
        }
        
        var body: some View {
            NavigationLink(value: paycheck) {
                VStack(alignment: .leading) {
                    Text(paycheck.name)
                        .font(.headline)
                    
                    Text(paycheck.date, format: .dateTime.month(.wide).year())
                        .font(.subheadline)
                }
            }
        }
    }
    
    private func deletePaychecks(at indices: IndexSet) {
        indices.forEach { modelContext.delete(paychecks[$0]) }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        PaychecksListView(selectedPayComponent: $selectedPayComponent)
    }
    .modelContainer(PreviewController.container)
}
