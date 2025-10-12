import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    init(for paycheck: Paycheck, selection: Binding<PayComponent?>) {
        self.paycheck = paycheck
        self._selection = selection
    }
    
    @Bindable private var paycheck: Paycheck
    @Binding private var selection: PayComponent?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") {
                PaycheckDetailView(for: paycheck)
            }
            
            Tab("Net Pay", systemImage: "plus.forwardslash.minus") {
                NetPayView(for: paycheck)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Copy", systemImage: "document.on.document") {
                    copyPaycheck()
                }
                
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deletePaycheck()
                    dismiss()
                }
            }
        }
    }
    
    private func copyPaycheck() {
        let paycheckDates = paychecks.map { $0.date }
        let currentMonth = Calendar.current.lastDateOfMonth(from: .now)!
        let newPaycheck = Paycheck()
        newPaycheck.name = paycheck.name + " (copy)"
        
        // if a paycheck exists for the current month, create a form a month past the latest date
        // contained in the current query
        if paycheckDates.contains(currentMonth) {
            let lastDate = paycheckDates.max()!
            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: lastDate)!
            newPaycheck.date = Calendar.current.lastDateOfMonth(from: nextDate)!
        }
        
        newPaycheck.payGrade = paycheck.payGrade
        newPaycheck.yearsOfService = paycheck.yearsOfService
        newPaycheck.basicPay = BasicPayTables.shared.basicPay(
            for: newPaycheck.year,
            as: newPaycheck.payGrade,
            with: newPaycheck.yearsOfService
        ) ?? paycheck.basicPay
        newPaycheck.bas = BASTables.shared.bas(
            for: newPaycheck.year,
            as: newPaycheck.payGrade
        ) ?? paycheck.bas
        newPaycheck.bah = paycheck.bah
        
        newPaycheck.lesItems = paycheck.lesItems?.map {
            LESItem(name: $0.name, amount: $0.amount, type: $0.type)
        }
        
        modelContext.insert(newPaycheck)
        selection = .paycheck(newPaycheck)
    }
    
    private func deletePaycheck() {
        modelContext.delete(paycheck)
        selection = nil
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        PaycheckTabView(for: paycheck, selection: .constant(nil))
    }
    .modelContainer(PreviewController.container)
}
