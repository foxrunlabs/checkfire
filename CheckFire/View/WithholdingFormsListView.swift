import SwiftData
import SwiftUI

struct WithholdingFormsListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    
    @State private var showAddWithholdingSheet = false
    
    var body: some View {
        Group {
            if withholdingForms.isEmpty {
                ContentUnavailableView(
                    "No Forms Found",
                    systemImage: "pencil.and.list.clipboard",
                    description: Text("Please add a new form.")
                )
            } else {
                List(selection: $selectedPayComponent) {
                    ForEach(withholdingForms) { withholdingForm in
                        WithholdingFormsListRow(for: withholdingForm)
                            .tag(PayComponent.withholdingForm(withholdingForm))
                    }
                    .onDelete(perform: deleteWithholdingForm)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Withholding Forms")
        .toolbar {
            ToolbarItem {
                Button("Add Withholding", systemImage: "plus") {
                    showAddWithholdingSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddWithholdingSheet) {
            AddWithholdingFormSheet(selectedPayComponent: $selectedPayComponent)
                .presentationDetents([.medium])
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

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        WithholdingFormsListView(selectedPayComponent: $selectedPayComponent)
    }
    .modelContainer(PreviewController.container)
}

