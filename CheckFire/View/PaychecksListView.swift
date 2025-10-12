import SwiftData
import SwiftUI

struct PaychecksListView: View {
    @Binding var selection: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    
    private enum SortOption: String {
        case date
        case name
    }
    
    @AppStorage("paycheckSortBy") private var sortBy = SortOption.date
    @AppStorage("paycheckSortOrder") private var sortOrder = SortOrder.forward
    
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
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .navigationTitle("Paychecks")
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
                        Button("Add Paycheck", systemImage: "plus") {
                            addPaycheck()
                        }
                    }
                }
                
                if #available(iOS 26, *) {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button("Add Paycheck", systemImage: "plus") {
                            addPaycheck()
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
    }
    
    private func addPaycheck() {
        let paycheckDates = paychecks.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newPaycheck = Paycheck()
        
        // if a paycheck exists for the current month, create a form a month past the latest date
        // contained in the current query
        if paycheckDates.contains(currentMonth) {
            let lastDate = paycheckDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newPaycheck.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
    }
    
    private struct QueryView: View {
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<Paycheck>]) {
            self._selection = selection
            self._paychecks = Query(sort: sort)
        }
        
        @Binding private var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var paychecks: [Paycheck]
        
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deletePaycheck(paycheck)
                                }
                                
                                Button("Copy", systemImage: "document.on.document") {
                                    copyPaycheck(paycheck)
                                }
                                .tint(.accentColor)
                            }
                    }
                }
                .listStyle(.inset)
            }
        }
        
        private struct PaycheckListRow: View {
            init(for paycheck: Paycheck) {
                self.paycheck = paycheck
            }
            
            private let paycheck: Paycheck
            
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
        
        private func copyPaycheck(_ other: Paycheck) {
            let paycheckDates = paychecks.map { $0.date }
            let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
            let newPaycheck = Paycheck()
            newPaycheck.name = other.name + " (copy)"
            
            // if a paycheck exists for the current month, create a form a month past the latest date
            // contained in the current query
            if paycheckDates.contains(currentMonth) {
                let lastDate = paycheckDates.max()!
                let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
                newPaycheck.date = Calendar.current.lastDateOfMonth(from: nextDate)!
            }
            
            newPaycheck.payGrade = other.payGrade
            newPaycheck.yearsOfService = other.yearsOfService
            newPaycheck.basicPay = BasicPayTables.shared.basicPay(
                for: newPaycheck.year,
                as: newPaycheck.payGrade,
                with: newPaycheck.yearsOfService
            ) ?? other.basicPay
            newPaycheck.bas = BASTables.shared.bas(
                for: newPaycheck.year,
                as: newPaycheck.payGrade
            ) ?? other.bas
            newPaycheck.bah = other.bah
            
            newPaycheck.lesItems = other.lesItems?.map {
                LESItem(name: $0.name, amount: $0.amount, type: $0.type)
            }
            
            modelContext.insert(newPaycheck)
            selection = .paycheck(newPaycheck)
        }
        
        private func deletePaycheck(_ paycheck: Paycheck) {
            modelContext.delete(paycheck)
            selection = nil
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
