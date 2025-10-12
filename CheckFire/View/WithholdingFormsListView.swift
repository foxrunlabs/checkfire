import SwiftData
import SwiftUI

struct WithholdingFormsListView: View {
    @Binding var selection: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    
    private enum SortOption: String {
        case date
        case name
    }
    
    @AppStorage("withholdingSortBy") private var sortBy = SortOption.date
    @AppStorage("withholdingSortOrder") private var sortOrder = SortOrder.forward
    
    private var sort: [SortDescriptor<WithholdingForm>] {
        switch sortBy {
        case .date:
            [SortDescriptor(\WithholdingForm.date, order: sortOrder)]
        case .name:
            [
                SortDescriptor(\WithholdingForm.name, order: sortOrder),
                SortDescriptor(\WithholdingForm.date, order: sortOrder)
            ]
        }
    }
    
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .navigationTitle("Withholding Forms")
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
                        Button("Add Form", systemImage: "plus") {
                            addWithholdingForm()
                        }
                    }
                }
                
                if #available(iOS 26, *) {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button("Add Form", systemImage: "plus") {
                            addWithholdingForm()
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
    }
    
    private func addWithholdingForm() {
        let formDates = withholdingForms.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newWithholdingForm = WithholdingForm()
        
        // if a form exists for the current month, create a form a month past the latest date
        // contained in the current query
        if formDates.contains(currentMonth) {
            let lastDate = formDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newWithholdingForm.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        modelContext.insert(newWithholdingForm)
        selection = .withholdingForm(newWithholdingForm)
    }
    
    private struct QueryView: View {
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<WithholdingForm>]) {
            self._selection = selection
            self._withholdingForms = Query(sort: sort)
        }
        
        @Binding private var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var withholdingForms: [WithholdingForm]
        
        var body: some View {
            if withholdingForms.isEmpty {
                ContentUnavailableView(
                    "No Forms Found",
                    systemImage: "pencil.and.list.clipboard",
                    description: Text("Please add a new form.")
                )
            } else {
                List(selection: $selection) {
                    ForEach(withholdingForms) { withholdingForm in
                        WithholdingFormsListRow(for: withholdingForm)
                            .tag(PayComponent.withholdingForm(withholdingForm))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteWithholdingForm(withholdingForm)
                                }
                                
                                Button("Copy", systemImage: "document.on.document") {
                                    copyWithholdingForm(withholdingForm)
                                }
                                .tint(.accentColor)
                            }
                    }
                }
                .listStyle(.inset)
            }

        }
        
        private struct WithholdingFormsListRow: View {
            init(for withholdingForm: WithholdingForm) {
                self.withholdingForm = withholdingForm
            }
            
            private let withholdingForm: WithholdingForm
            
            var body: some View {
                NavigationLink(value: withholdingForm) {
                    VStack(alignment: .leading) {
                        Text(withholdingForm.name)
                            .font(.headline)
                        
                        Text(withholdingForm.date, format: .dateTime.month(.wide).year())
                            .font(.subheadline)
                    }
                }
            }
        }
        
        private func copyWithholdingForm(_ other: WithholdingForm) {
            let formDates = withholdingForms.map { $0.date }
            let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
            let newWithholdingForm = WithholdingForm()
            newWithholdingForm.name = other.name + " (copy)"
            
            // if a form exists for the current month, create a form a month past the latest date
            // contained in the current query
            if formDates.contains(currentMonth) {
                let lastDate = formDates.max()!
                let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
                newWithholdingForm.date = Calendar.current.lastDateOfMonth(from: nextDate)!
            }
            
            newWithholdingForm.maritalStatus = other.maritalStatus
            newWithholdingForm.multipleJobs = other.multipleJobs
            newWithholdingForm.childDependents = other.childDependents
            newWithholdingForm.otherDependents = other.otherDependents
            newWithholdingForm.otherIncome = other.otherIncome
            newWithholdingForm.deductions = other.deductions
            newWithholdingForm.extraWithholding = other.extraWithholding
            
            modelContext.insert(newWithholdingForm)
            selection = .withholdingForm(newWithholdingForm)
        }
        
        private func deleteWithholdingForm(_ withholdingForm: WithholdingForm) {
            modelContext.delete(withholdingForm)
            selection = nil
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        WithholdingFormsListView(selection: $selectedPayComponent)
    }
    .modelContainer(PreviewController.container)
}

