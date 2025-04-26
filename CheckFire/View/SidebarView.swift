import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @State private var sortOrder = [
        SortDescriptor(\Paycheck.lesData.date),
        SortDescriptor(\Paycheck.name)
    ]
    
    @State private var showAbout = false
    @State private var showAlert = false
    
    private var aboutString: String {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        return "About " + appName
    }
    
    var body: some View {
        QueryView(selectedPaycheck: $selectedPaycheck, sortBy: sortOrder)
            .navigationTitle("Paychecks")
            .toolbar {
                ToolbarItem {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button(aboutString, systemImage: "info.circle") {
                            showAbout.toggle()
                        }
                        
                        if !paychecks.isEmpty {
                            Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                                Picker("Sort By", selection: $sortOrder) {
                                    Text("Date")
                                        .tag([
                                            SortDescriptor(\Paycheck.lesData.date),
                                            SortDescriptor(\Paycheck.name)
                                        ])
                                    
                                    Text("Name")
                                        .tag([
                                            SortDescriptor(\Paycheck.name),
                                            SortDescriptor(\Paycheck.lesData.date)
                                        ])
                                }
                                .pickerStyle(.inline)
                            }
                        
                            Button("Delete Paychecks", systemImage: "trash", role: .destructive) {
                                showAlert.toggle()
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Button("Add Paycheck", systemImage: "square.and.pencil") {
                        addPaycheck()
                    }
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert("Delete Paychecks", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    deleteAllPaychecks()
                }
            } message: {
                Text("Are you sure?")
            }
    }
    
    private func addPaycheck() {
        let newPaycheck = Paycheck(name: "New Paycheck")
        modelContext.insert(newPaycheck)
        
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        withAnimation { selectedPaycheck = newPaycheck }
    }
    
    private func deleteAllPaychecks() {
        do {
            try modelContext.delete(model: Paycheck.self)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        withAnimation { selectedPaycheck = nil }
    }
}

fileprivate struct QueryView: View {
    @Binding var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    init(selectedPaycheck: Binding<Paycheck?>, sortBy: [SortDescriptor<Paycheck>]) {
        self._selectedPaycheck = selectedPaycheck
        self._paychecks = Query(sort: sortBy)
    }
    
    var body: some View {
        List(paychecks, selection: $selectedPaycheck.animation()) { paycheck in
            NavigationLink(value: paycheck) {
                VStack(alignment: .leading) {
                    Text(paycheck.name)
                        .bold()
                    
                    Text(paycheck.lesData.date.formatted(.dateTime.month(.wide).year()))
                }
                .padding(.vertical, ProcessInfo.processInfo.isiOSAppOnMac ? 8 : 0)
            }
            .swipeActions {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deletePaycheck(paycheck)
                }
                
                Button("Copy", systemImage: "document.on.document") {
                    copyPaycheck(paycheck)
                }
                .tint(.blue)
            }
        }
        .listStyle(.inset)
    }
    
    private func copyPaycheck(_ paycheck: Paycheck) {
        let newPaycheck = Paycheck(paycheck)
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

#Preview {
    @Previewable @State var paycheck: Paycheck? = Paycheck.example
    SidebarView(selectedPaycheck: $paycheck)
        .modelContainer(PreviewController.container)
}
