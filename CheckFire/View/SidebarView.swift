import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding private var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    @State private var sortBy = SortOption.date
    @State private var sortOrder = SortOrder.forward
    
    @State private var showAbout = false
    @State private var showAlert = false
    
    private enum SortOption {
        case date
        case name
    }
    
    private var aboutLabel: String {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "App"
        return "About " + appName
    }
    
    private var sort: [SortDescriptor<Paycheck>] {
        switch sortBy {
        case .date:
                [SortDescriptor(\Paycheck.lesData.date, order: sortOrder),
                SortDescriptor(\Paycheck.name, order: sortOrder)]
        case .name:
                [SortDescriptor(\Paycheck.name, order: sortOrder),
                SortDescriptor(\Paycheck.lesData.date, order: sortOrder)]
        }
    }
    
    private var ascendingLabel: String { sortBy == .date ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .date ? "Newest First" : "Z to A" }
    
    init(selection: Binding<Paycheck?>) {
        self._selectedPaycheck = selection
    }
    
    var body: some View {
        QueryView(selection: $selectedPaycheck, sort: sort)
            .navigationTitle("Paychecks")
            .toolbar {
                ToolbarItem {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button(aboutLabel, systemImage: "info.circle") { showAbout.toggle() }
                        
                        if !paychecks.isEmpty {
                            Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                                Picker("Sort By", selection: $sortBy.animation()) {
                                    Text("Date")                                        .tag(SortOption.date)
                                    
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
                        
                            Button("Delete Paychecks", systemImage: "trash", role: .destructive) {
                                showAlert.toggle()
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    
                    Button("Add Paycheck", systemImage: "square.and.pencil") { addPaycheck() }
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert("Delete Paychecks", isPresented: $showAlert) {
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    Button("Delete") { deleteAllPaychecks() }
                        .keyboardShortcut(.defaultAction)
                    
                    Button("Cancel") { }
                        .keyboardShortcut(.cancelAction)
                } else {
                    Button("Cancel", role: .cancel) { }
                    
                    Button("Delete", role: .destructive) { deleteAllPaychecks() }
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

#Preview {
    @Previewable @State var paycheck: Paycheck? = Paycheck.example
    SidebarView(selection: $paycheck)
        .modelContainer(PreviewController.container)
}
