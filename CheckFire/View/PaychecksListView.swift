import Foundation
import SwiftData
import SwiftUI

struct PaychecksListView: View {
    private enum SortOption: String {
        case date
        case name
    }
    
    // MARK: - Properties
    @Binding var selection: DetailSelection?
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("paycheckSortBy") private var sortBy = SortOption.date
    @AppStorage("paycheckSortOrder") private var sortOrder = SortOrder.forward
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
    private var sort: [SortDescriptor<Paycheck>] {
        switch sortBy {
        case .date:
            [
                SortDescriptor(\Paycheck.date, order: sortOrder),
                SortDescriptor(\Paycheck.name, order: sortOrder)
            ]
        case .name:
            [
                SortDescriptor(\Paycheck.name, order: sortOrder),
                SortDescriptor(\Paycheck.date, order: sortOrder)
            ]
        }
    }
    
    // MARK: - Body
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
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button("Add Paycheck", systemImage: "plus") { addPaycheck() }
                        .buttonStyle(.glassProminent)
                }
            }
    }
    
    // MARK: - Methods
    private func addPaycheck() {
        let newPaycheck = Paycheck()
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
    }
}


// MARK: - Query View
fileprivate struct QueryView: View {
    @Binding var selection: DetailSelection?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    // MARK: - Initializer
    init(selection: Binding<DetailSelection?>, sort: [SortDescriptor<Paycheck>]) {
        self._selection = selection
        self._paychecks = Query(sort: sort)
    }
    
    // MARK: - Body
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
                    ListRow(paycheck: paycheck)
                        .tag(DetailSelection.paycheck(paycheck))
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
    
    // MARK: - Methods
    private func copyPaycheck(_ other: Paycheck) {
        let newPaycheck = Paycheck(other)
        newPaycheck.name = other.name + " (copy)"
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
        selection = nil
    }
}


// MARK: - List Row
fileprivate struct ListRow: View {
    let paycheck: Paycheck
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            Text(paycheck.name)
                .font(.headline)
            
            Text(paycheck.date, format: .dateTime.month(.wide).year())
                .font(.subheadline)
        }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var selection: DetailSelection?
    
    NavigationStack {
        PaychecksListView(selection: $selection)
    }
    .modelContainer(PreviewController.container)
}
