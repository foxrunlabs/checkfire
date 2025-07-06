import SwiftData
import SwiftUI

struct WithholdingFormsListView: View {
    @Binding var selection: PayComponent?
    
    @State private var showAddWithholdingSheet = false
    
    private enum SortOption {
        case date
        case name
    }
    
    @State private var sortBy = SortOption.date
    @State private var sortOrder = SortOrder.forward
    
    var body: some View {
        QueryView(selection: $selection, sort: sort)
            .listStyle(.inset)
            .navigationTitle("Withholding Forms")
            .toolbar {
                ToolbarItem {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("Add Form", systemImage: "document") {
                            showAddWithholdingSheet.toggle()
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
            .sheet(isPresented: $showAddWithholdingSheet) {
                AddWithholdingFormSheet(selection: $selection)
                    .presentationDetents([.medium])
            }
    }
    
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
    
    private struct QueryView: View {
        @Binding var selection: PayComponent?
        
        @Environment(\.modelContext) private var modelContext
        @Query private var withholdingForms: [WithholdingForm]
        
        init(selection: Binding<PayComponent?>, sort: [SortDescriptor<WithholdingForm>]) {
            self._selection = selection
            self._withholdingForms = Query(sort: sort)
        }
        
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
                    }
                    .onDelete(perform: deleteWithholdingForm)
                }
            }

        }
        
        private struct WithholdingFormsListRow: View {
            let withholdingForm: WithholdingForm
            
            init(for withholdingForm: WithholdingForm) {
                self.withholdingForm = withholdingForm
            }
            
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
        
        private func deleteWithholdingForm(at indices: IndexSet) {
            indices.forEach { modelContext.delete(withholdingForms[$0]) }
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

