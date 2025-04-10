import SwiftData
import SwiftUI

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    var body: some View {
        List {
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
        .navigationDestination(for: Paycheck.self) {
            PaycheckView(paycheck: $0)
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
    }
    
    private func deletePaycheck(indices: IndexSet) {
        indices.forEach { modelContext.delete(paychecks[$0]) }
    }
}

#Preview {
    SidebarView()
        .modelContainer(PreviewController.container)
}
