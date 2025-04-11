import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    var body: some View {
        List(selection: $selectedPaycheck.animation()) {
            ForEach(paychecks) { paycheck in
                NavigationLink(value: paycheck) {
                    VStack(alignment: .leading) {
                        Text(paycheck.name)
                            .bold()
                        
                        Text(paycheck.date, style: .date)
                    }
                }
            }
            .onDelete(perform: deletePaycheck)
        }
        .navigationTitle("Paychecks")
        .toolbar {
            ToolbarItem {
                EditButton()
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                
                Button("Add Paycheck", systemImage: "square.and.pencil") {
                    addPaycheck()
                }
            }
        }
    }
    
    private func addPaycheck() {
        let newPaycheck = Paycheck(name: "New Paycheck", date: .now)
        modelContext.insert(newPaycheck)
        withAnimation { selectedPaycheck = newPaycheck }
    }
    
    private func deletePaycheck(indices: IndexSet) {
        indices.forEach { modelContext.delete(paychecks[$0]) }
        withAnimation { selectedPaycheck = nil }
    }
}

#Preview {
    @Previewable @State var paycheck: Paycheck? = Paycheck.example
    SidebarView(selectedPaycheck: $paycheck)
        .modelContainer(PreviewController.container)
}
