import SwiftData
import SwiftUI

struct TSPListView: View {
    @Binding var selection: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    private enum SortOption: String {
        case date
        case name
    }
    
    @AppStorage("tspSortBy") private var sortBy = SortOption.date
    @AppStorage("tspSortOrder") private var sortOrder = SortOrder.forward
    
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
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
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .navigationTitle("Thrift Savings Plans")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
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
                    
                    if #unavailable(iOS 26) {
                        Button("Add Plan", systemImage: "plus") {
                            addTSP()
                        }
                    }
                }
                
                if #available(iOS 26, *) {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button("Add Plan", systemImage: "plus") {
                            addTSP()
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
    }
    
    private func addTSP() {
        let tspDates = thriftSavingsPlans.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newTSP = ThriftSavingsPlan()
        
        // if a plan exists for the current month, create a plan a month past the latest date
        // contained in the current query
        if tspDates.contains(currentMonth) {
            let lastDate = tspDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newTSP.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        modelContext.insert(newTSP)
        selection = .thriftSavingsPlan(newTSP)
    }
    
    private struct QueryView: View {
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<ThriftSavingsPlan>]) {
            self._selection = selection
            self._thriftSavingsPlans = Query(sort: sort)
        }
        
        @Binding private var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var thriftSavingsPlans: [ThriftSavingsPlan]
        
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteTSP(tsp)
                                }
                                
                                Button("Copy", systemImage: "document.on.document") {
                                    copyTSP(tsp)
                                }
                                .tint(.accentColor)
                            }
                    }
                }
                .listStyle(.inset)
            }
        }
        
        private struct TSPListRow: View {
            init(for tsp: ThriftSavingsPlan) {
                self.tsp = tsp
            }
            
            private let tsp: ThriftSavingsPlan
            
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
        
        private func copyTSP(_ other: ThriftSavingsPlan) {
            let tspDates = thriftSavingsPlans.map { $0.date }
            let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
            let newTSP = ThriftSavingsPlan()
            newTSP.name = other.name + " (copy)"
            
            // if a plan exists for the current month, create a plan a month past the latest date
            // contained in the current query
            if tspDates.contains(currentMonth) {
                let lastDate = tspDates.max()!
                let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
                newTSP.date = Calendar.current.lastDateOfMonth(from: nextDate)!
            }
            
            newTSP.traditionalBasicPay = other.traditionalBasicPay
            newTSP.traditionalSpecialPay = other.traditionalSpecialPay
            newTSP.traditionalIncentivePay = other.traditionalIncentivePay
            newTSP.traditionalBonusPay = other.traditionalBonusPay
            newTSP.rothBasicPay = other.rothBasicPay
            newTSP.rothSpecialPay = other.rothSpecialPay
            newTSP.rothIncentivePay = other.rothIncentivePay
            newTSP.rothBonusPay = other.rothBonusPay
            
            modelContext.insert(newTSP)
            selection = .thriftSavingsPlan(newTSP)
        }
        
        private func deleteTSP(_ tsp: ThriftSavingsPlan) {
            modelContext.delete(tsp)
            selection = nil
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


