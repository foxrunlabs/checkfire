import SwiftData
import SwiftUI

struct TSPListView: View {
    @Binding var selectedPayComponent: PayComponent?
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Paycheck.date) private var paychecks: [Paycheck]
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    var body: some View {
        List(selection: $selectedPayComponent) {
            ForEach(thriftSavingsPlans) { tsp in
                TSPListRow(tsp: tsp)
                    .swipeActions(allowsFullSwipe: false) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteTSP(tsp)
                        }

                        Button("Copy", systemImage: "document.on.document")
                        {
                            
                        }
                        .tint(.accentColor)
                    }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Thrift Savings Plans")
        .toolbar {
            ToolbarItem {
                Button("Add TSP", systemImage: "plus") {
                    addTSP()
                }
            }
        }
    }
    
    private struct TSPListRow: View {
        let tsp: ThriftSavingsPlan
        
        var body: some View {
            NavigationLink(value: tsp) {
                VStack(alignment: .leading) {
                    Text(tsp.name)
                        .font(.headline)
                    Text(tsp.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                }
            }
            .tag(PayComponent.thriftSavingsPlan(tsp))
        }
    }
    
    private func addTSP() {
        let newDate = Calendar.current.lastDateOfMonth(from: .now) ?? .now
        let applicablePaychecks = paychecks.filter { $0.date >= newDate }
        
        let newTSP = ThriftSavingsPlan(
            name: "New TSP",
            date: .now,
            traditionalBasePay: 0.00,
            traditionalSpecialPay: 0.00,
            traditionalIncentivePay: 0.00,
            traditionalBonusPay: 0.00,
            rothBasePay: 0.00,
            rothSpecialPay: 0.00,
            rothIncentivePay: 0.00,
            rothBonusPay: 0.00,
            paychecks: applicablePaychecks
        )
        
        modelContext.insert(newTSP)
        selectedPayComponent = .thriftSavingsPlan(newTSP)
    }
    
    private func deleteTSP(_ tsp: ThriftSavingsPlan) {
        let paychecks = tsp.paychecks
        modelContext.delete(tsp)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        if let paychecks {
            paychecks.forEach { paycheck in
                paycheck.thriftSavingsPlan = thriftSavingsPlans.last { $0.date <= paycheck.date }
            }
        }
        
        selectedPayComponent = nil
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


