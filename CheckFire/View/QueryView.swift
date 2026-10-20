import Foundation
import SwiftData
import SwiftUI

struct QueryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    // MARK: - Initializer
    
    init(sort: [SortDescriptor<Paycheck>]) {
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
            List {
                ForEach(paychecks) { paycheck in
                    ListRow(paycheck: paycheck)
                        .tag(paycheck)
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
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
    }
}


// MARK: - List Row

fileprivate struct ListRow: View {
    let paycheck: Paycheck
    
    // MARK: - Body
    var body: some View {
        NavigationLink {
            PaycheckDetailView(paycheck: paycheck)
        } label: {
            VStack(alignment: .leading) {
                Text(paycheck.name)
                    .font(.headline)
                
                Text(paycheck.date, format: .dateTime.month(.wide).year())
                    .font(.subheadline)
            }
        }
    }
}
