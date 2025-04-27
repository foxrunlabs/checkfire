import SwiftData
import SwiftUI

extension SidebarView {
    struct QueryView: View {
        @Binding private var selectedPaycheck: Paycheck?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var paychecks: [Paycheck]
        
        init(selection: Binding<Paycheck?>, sort: [SortDescriptor<Paycheck>]) {
            self._selectedPaycheck = selection
            self._paychecks = Query(sort: sort)
        }
        
        var body: some View {
            List(paychecks, selection: $selectedPaycheck.animation()) { paycheck in
                NavigationLink(value: paycheck) {
                    VStack(alignment: .leading) {
                        Text(paycheck.name)
                            .bold()
                        
                        Text(paycheck.lesData.date.formatted(.dateTime.month(.wide).year()))
                    }
                    .padding(.vertical, ProcessInfo.processInfo.isiOSAppOnMac ? 8 : 0)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deletePaycheck(paycheck)
                    }
                    
                    Button("Copy", systemImage: "document.on.document") { copyPaycheck(paycheck) }
                        .tint(.blue)
                }
            }
            .listStyle(.inset)
        }
        
        private func copyPaycheck(_ paycheck: Paycheck) {
            let newPaycheck = Paycheck(paycheck)
            modelContext.insert(newPaycheck)
            
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            
            withAnimation { selectedPaycheck = newPaycheck }
        }
        
        private func deletePaycheck(_ paycheck: Paycheck) {
            modelContext.delete(paycheck)
            withAnimation { selectedPaycheck = nil }
        }
    }
}
