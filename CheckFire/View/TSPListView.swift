import SwiftData
import SwiftUI

struct TSPListView: View {
    @Binding var selection: PayComponent?
    
    @State private var showAddTSPSheet = false
    
    private enum SortOption {
        case date
        case name
    }
    
    @State private var sortBy = SortOption.date
    @State private var sortOrder = SortOrder.forward
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .listStyle(.inset)
            .navigationTitle("Thrift Savings Plans")
            .toolbar {
                ToolbarItem {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("Add Plan", systemImage: "document") {
                            showAddTSPSheet.toggle()
                        }
                        
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
                    }
                }
            }
            .sheet(isPresented: $showAddTSPSheet) {
                AddTSPSheet(selection: $selection)
                    .presentationDetents([.medium])
            }
    }
    
    private var sort: [SortDescriptor<ThriftSavingsPlan>] {
        switch sortBy {
        case .date:
            [SortDescriptor(\ThriftSavingsPlan.date, order: sortOrder)]
        case .name:
            [
                SortDescriptor(\ThriftSavingsPlan.name, order: sortOrder),
                SortDescriptor(\ThriftSavingsPlan.date, order: sortOrder)
            ]
        }
    }
    
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
    private struct QueryView: View {
        @Binding var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
        
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<ThriftSavingsPlan>]) {
            self._selection = selection
            self._thriftSavingsPlans = Query(sort: sort)
        }
        
        var body: some View {
            if thriftSavingsPlans.isEmpty {
                ContentUnavailableView(
                    "No Plans Found",
                    systemImage: "dollarsign.bank.building",
                    description: Text("Please add a new plan.")
                )
            } else {
                List(selection: $selection) {
                    ForEach(thriftSavingsPlans) { tsp in
                        TSPListRow(for: tsp)
                            .tag(PayComponent.thriftSavingsPlan(tsp))
                    }
                    .onDelete(perform: deleteTSP)
                }
            }
        }
        
        private struct TSPListRow: View {
            let tsp: ThriftSavingsPlan
            
            init(for tsp: ThriftSavingsPlan) {
                self.tsp = tsp
            }
            
            var body: some View {
                NavigationLink(value: tsp) {
                    VStack(alignment: .leading) {
                        Text(tsp.name)
                            .font(.headline)
                        
                        Text(tsp.date, format: .dateTime.month(.wide).year())
                            .font(.subheadline)
                    }
                }
            }
        }
        
        private func deleteTSP(at indices: IndexSet) {
            indices.forEach { modelContext.delete(thriftSavingsPlans[$0]) }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        TSPListView(selection: $selectedPayComponent)
    }
    .modelContainer(PreviewController.container)
}


