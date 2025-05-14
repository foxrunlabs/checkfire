import SwiftData
import SwiftUI

struct QueryView: View {
    @Binding private var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Environment(ThemeManager.self) private var themeManager
    
    init(selection: Binding<Paycheck?>, sort: [SortDescriptor<Paycheck>]) {
        self._selectedPaycheck = selection
        self._paychecks = Query(sort: sort)
    }
    
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    var body: some View {
        List(paychecks, selection: $selectedPaycheck.animation()) { paycheck in
            NavigationLink(value: paycheck) {
                PaycheckItem(paycheck)
            }
            .listRowBackground(
                isPhone ? (selectedPaycheck == paycheck ? themeManager.listSelection :  Color.clear)
                        : nil
            )
            .listRowSeparatorTint(themeManager.listRowSeparator)
            .swipeActions(allowsFullSwipe: false) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deletePaycheck(paycheck)
                }
                .tint(.red)
                
                Button("Copy", systemImage: "document.on.document")
                {
                    copyPaycheck(paycheck)
                }
                .tint(.accentColor)
            }
        }
        .listStyle(.inset)
        .checkFireListBackground(themeManager: themeManager)
    }
    
    private struct PaycheckItem: View {
        let paycheck: Paycheck
        
        init(_ paycheck: Paycheck) {
            self.paycheck = paycheck
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(paycheck.name)
                    .bold()
                
                Text(paycheck.lesData.date.formatted(.dateTime.month(.wide).year()))
            }
            .padding(.vertical, ProcessInfo.processInfo.isiOSAppOnMac ? 8 : 0)
        }
    }
    
    private func copyPaycheck(_ paycheck: Paycheck) {
        let newPaycheck = Paycheck(paycheck)
        newPaycheck.name += " copy"
        modelContext.insert(newPaycheck)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        withAnimation { selectedPaycheck = newPaycheck }
    }
    
    private func deletePaycheck(_ paycheck: Paycheck) {
        modelContext.delete(paycheck)
        withAnimation { selectedPaycheck = nil }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck: Paycheck? = nil
    let sort = [SortDescriptor(\Paycheck.name)]
    
    NavigationStack {
        QueryView(selection: $paycheck, sort: sort)
            .modelContainer(PreviewController.container)
    }
    .environment(ThemeManager(theme: .system))
}
