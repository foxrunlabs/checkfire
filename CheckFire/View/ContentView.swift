import Foundation
import SwiftData
import SwiftUI

struct ContentView: View {
    private enum DefaultsKey {
        static let sortBy = "net.thefoxrun.labs.CheckFire.paycheckSortBy"
        static let sortOrder = "net.thefoxrun.labs.CheckFire.paycheckSortOrder"
    }
    
    private enum SortOption: String {
        case payPeriod
        case name
    }
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage(DefaultsKey.sortBy) private var sortBy = SortOption.payPeriod
    @AppStorage(DefaultsKey.sortOrder) private var sortOrder = SortOrder.forward
    
    @State private var path = NavigationPath()
    @State private var showSettings = false
    
    // MARK: - Computed Properties
    
    private var ascendingLabel: String { sortBy == .payPeriod ? "Oldest First" : "A to Z" }
    private var descendingLabel: String { sortBy == .payPeriod ? "Newest First" : "Z to A" }
    
    private var sort: [SortDescriptor<Paycheck>] {
        switch sortBy {
        case .payPeriod:
            [
                SortDescriptor(\Paycheck.year, order: sortOrder),
                SortDescriptor(\Paycheck.month.rawValue, order: sortOrder),
                SortDescriptor(\Paycheck.name, order: sortOrder)
            ]
        case .name:
            [
                SortDescriptor(\Paycheck.name, order: sortOrder),
                SortDescriptor(\Paycheck.year, order: sortOrder),
                SortDescriptor(\Paycheck.month.rawValue, order: sortOrder)             
            ]
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $path) {
            QueryView(sort: sort)
                .navigationTitle("CheckFire")
                .navigationSubtitle("Paychecks")
                .navigationDestination(for: Paycheck.self) { paycheck in
                    PaycheckDetailView(paycheck: paycheck)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gear") { showSettings = true }
                            .accessibilityLabel("App settings")
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort By", selection: $sortBy) {
                                Text("Date").tag(SortOption.payPeriod)
                                Text("Name").tag(SortOption.name)
                            }
                            .pickerStyle(.inline)
                            
                            Picker("Sort Order", selection: $sortOrder.animation()) {
                                Text(ascendingLabel).tag(SortOrder.forward)
                                Text(descendingLabel).tag(SortOrder.reverse)
                            }
                            .pickerStyle(.inline)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button("Add Paycheck", systemImage: "plus") { addPaycheck() }
                            .buttonStyle(.glassProminent)
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
        }
    }
    
    // MARK: - Methods
    
    private func addPaycheck() {
        let newPaycheck = Paycheck()
        modelContext.insert(newPaycheck)
        path.append(newPaycheck)
    }
}


// MARK: - Preview

#Preview {
    ContentView()
        .environment(PreviewController.paySystem)
        .modelContainer(PreviewController.container)
}
