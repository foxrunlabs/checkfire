import SwiftData
import SwiftUI

struct PaychecksListView: View {
    @Binding var selection: PayComponent?
    
    @State private var showAddPaycheckSheet = false
    
    private enum SortOption {
        case date
        case name
    }
    
    @State private var sortBy = SortOption.date
    @State private var sortOrder = SortOrder.forward
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .listStyle(.inset)
            .navigationTitle("Paychecks")
            .toolbar {
                ToolbarItem {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("Add Paycheck", systemImage: "plus") {
                            showAddPaycheckSheet.toggle()
                        }
                        .tint(.accentColor)
                        
                        Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort By", selection: $sortBy) {
                                Text("Date")
                                    .tag(SortOption.date)
                                
                                Text("Name")
                                    .tag(SortOption.name)
                            }
                            .pickerStyle(.inline)
                            
                            Picker("Sort Order", selection: $sortOrder.animation()) {
                                Text(ascendingLabel)
                                    .tag(SortOrder.forward)
                                
                                Text(descendingLabel)
                                    .tag(SortOrder.reverse)
                            }
                            .pickerStyle(.inline)
                        }
                        .tint(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showAddPaycheckSheet) {
                AddPaycheckSheet(selection: $selection)
                    .presentationDetents([.medium])
            }
    }
    
    private var sort: [SortDescriptor<Paycheck>] {
        switch sortBy {
        case .date:
            [SortDescriptor(\Paycheck.date, order: sortOrder)]
        case .name:
            [
                SortDescriptor(\Paycheck.name, order: sortOrder),
                SortDescriptor(\Paycheck.date, order: sortOrder)
            ]
        }
    }
    
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
    private struct QueryView: View {
        @Binding var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var paychecks: [Paycheck]
        
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<Paycheck>]) {
            self._selection = selection
            self._paychecks = Query(sort: sort)
        }
        
        var body: some View {
            if paychecks.isEmpty {
                ContentUnavailableView(
                    "No Paychecks Found",
                    systemImage: "dollarsign",
                    description: Text("Please add a new paycheck.")
                )
            } else {
                List(selection: $selection) {
                    ForEach(paychecks) { paycheck in
                        PaycheckListRow(for: paycheck)
                            .tag(PayComponent.paycheck(paycheck))
                    }
                    .onDelete(perform: deletePaychecks)
                }
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
}

// MARK: - Preview
#Preview {
    @Previewable @State var selection: PayComponent?
    
    NavigationStack {
        PaychecksListView(selection: $selection)
    }
    .modelContainer(PreviewController.container)
}
