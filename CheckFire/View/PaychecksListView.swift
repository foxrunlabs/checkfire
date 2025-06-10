import SwiftData
import SwiftUI

struct PaychecksListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    var body: some View {
        List(selection: $selectedPayComponent) {
            ForEach(paychecks) { paycheck in
                PaycheckListRow(paycheck: paycheck)
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deletePaycheck(paycheck)
                        }

                        Button("Copy", systemImage: "document.on.document")
                        {
                            
                        }
                        .tint(.accentColor)
                    }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Paychecks")
        .toolbar {
            ToolbarItem {
                Button("Add Paycheck", systemImage: "plus") {
                    addPaycheck()
                }
            }
        }
    }
    
    private struct PaycheckListRow: View {
        let paycheck: Paycheck
        
        var body: some View {
            NavigationLink(value: paycheck) {
                VStack(alignment: .leading) {
                    Text(paycheck.name)
                        .font(.headline)
                    Text(paycheck.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                }
            }
            .tag(PayComponent.paycheck(paycheck))
        }
    }
    
    private func addPaycheck() {
        let newPaycheck = Paycheck(
            name: "New Paycheck",
            date: .now,
            payGrade: .e1,
            yearsOfService: .lessThanOrEqual2,
            basePay: 0.00
        )
        
        modelContext.insert(newPaycheck)
        selectedPayComponent = .paycheck(newPaycheck)
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
        selectedPayComponent = nil
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
