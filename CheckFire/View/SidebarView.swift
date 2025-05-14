import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding private var selectedTheme: Theme
    @Binding private var selectedPaycheck: Paycheck?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    @State private var sortBy = SortOption.date
    @State private var sortOrder = SortOrder.forward
    
    @State private var showAbout = false
    @State private var showAlert = false
    
    @Environment(ThemeManager.self) private var themeManager
    
    init(theme: Binding<Theme>, selection: Binding<Paycheck?>) {
        self._selectedTheme = theme
        self._selectedPaycheck = selection
    }
    
    private enum SortOption {
        case date
        case name
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
    
    var body: some View {
        QueryView(selection: $selectedPaycheck, sort: sort)
            .navigationTitle("Paychecks")
            .navigationBarTitleDisplayMode(
                UIDevice.current.userInterfaceIdiom == .pad ? .inline : .automatic
            )
            .checkFireNavigationBarStyle(themeManager: themeManager)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        Button("About CheckFire", systemImage: "info.circle") { showAbout.toggle() }
                        
                        Menu("Theme", systemImage: "paintbrush") {
                            Picker("Theme", selection: $selectedTheme.animation()) {
                                ForEach(Theme.allCases) { theme in
                                    Text(String(describing: theme))
                                        .tag(theme)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                        
                        if paychecks.count < 2 {
                            Label("Sort By", systemImage: "arrow.up.arrow.down")
                                .disabled(true)
                        } else {
                            Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                                Picker("Sort By", selection: $sortBy.animation()) {
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
                    
                        Button("Delete Paychecks", systemImage: "trash", role: .destructive) {
                            showAlert.toggle()
                        }
                        .tint(.red)
                        .disabled(paychecks.isEmpty)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
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
            .overlay {
                if paychecks.isEmpty {
                    ContentUnavailableView(
                        "No Paychecks",
                        systemImage: "dollarsign",
                        description: Text("Enter your first paycheck.")
                    )
                }
            }
            .onChange(of: selectedTheme) {
                withAnimation { themeManager.theme = selectedTheme }
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

// MARK: - Preview
#Preview {
    @Previewable @State var theme = Theme.system
    @Previewable @State var paycheck: Paycheck? = Paycheck.example
    
    NavigationStack {
        SidebarView(theme: $theme, selection: $paycheck)
            .modelContainer(PreviewController.container)
    }
    .environment(ThemeManager(theme: .system))
}
