import SwiftData
import SwiftUI

struct TSPListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showAddTSPSheet = false
    
    var body: some View {
        Group {
            if thriftSavingsPlans.isEmpty {
                ContentUnavailableView(
                    "No Plans Found",
                    systemImage: "dollarsign.bank.building",
                    description: Text("Please add a new plan.")
                )
            } else {
                List(selection: $selectedPayComponent) {
                    ForEach(thriftSavingsPlans) { tsp in
                        TSPListRow(for: tsp)
                            .tag(PayComponent.thriftSavingsPlan(tsp))
                    }
                    .onDelete(perform: deleteTSP)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Thrift Savings Plans")
        .toolbar {
            ToolbarItem {
                Button("Add TSP", systemImage: "plus") {
                    showAddTSPSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddTSPSheet) {
            AddTSPSheet(selectedPayComponent: $selectedPayComponent)
                .presentationDetents([.medium])
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
        indices.forEach { index in
            modelContext.delete(thriftSavingsPlans[index])
            
            do {
                try modelContext.save()
            } catch {
                fatalError(error.localizedDescription)
            }
            
            // re-associate paychecks to remaining TSPs
            thriftSavingsPlans.forEach { tsp in
                tsp.paychecks = paychecks.filter { paycheck in
                    paycheck.date >= tsp.date
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        TSPListView(selectedPayComponent: $selectedPayComponent)
    }
    .modelContainer(PreviewController.container)
}


