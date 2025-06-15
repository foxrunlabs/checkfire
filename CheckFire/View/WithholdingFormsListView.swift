import SwiftData
import SwiftUI

struct WithholdingFormsListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    
    var body: some View {
        List(selection: $selectedPayComponent) {
            ForEach(withholdingForms) { withholdingForm in
                WithholdingFormsListRow(withholdingForm: withholdingForm)
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteWithholdingForm(withholdingForm)
                        }

                        Button("Copy", systemImage: "document.on.document")
                        {
                            
                        }
                        .tint(.accentColor)
                    }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Withholding Forms")
        .toolbar {
            ToolbarItem {
                Button("Add Withholding", systemImage: "plus") {
                    addWithholdingForm()
                }
            }
        }
    }
    
    private struct WithholdingFormsListRow: View {
        let withholdingForm: WithholdingForm
        
        var body: some View {
            NavigationLink(value: withholdingForm) {
                VStack(alignment: .leading) {
                    Text(withholdingForm.name)
                        .font(.headline)
                    Text(withholdingForm.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                }
            }
            .tag(PayComponent.withholdingForm(withholdingForm))
        }
    }
    
    private func addWithholdingForm() {
        let newDate = Calendar.current.lastDateOfMonth(from: .now) ?? .now
        let applicablePaychecks = paychecks.filter { $0.date >= newDate }
        
        let newWithholdingForm = WithholdingForm(
            name: "New Withholding",
            date: .now,
            maritalStatus: .single,
            multipleJobs: false,
            childDependents: 0,
            otherDependents: 0,
            otherIncome: 0.00,
            deductions: 0.00,
            extraWithholding: 0.00,
            paychecks: applicablePaychecks
        )
        
        modelContext.insert(newWithholdingForm)
        selectedPayComponent = .withholdingForm(newWithholdingForm)
    }
    
    private func deleteWithholdingForm(_ withholdingForm: WithholdingForm) {
        let paychecks = withholdingForm.paychecks
        modelContext.delete(withholdingForm)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        if let paychecks {
            paychecks.forEach { paycheck in
                paycheck.withholdingForm = withholdingForms.last { $0.date <= paycheck.date }
            }
        }
        
        selectedPayComponent = nil
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

