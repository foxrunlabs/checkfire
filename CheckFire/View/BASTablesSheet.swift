import SwiftUI

struct BASTablesSheet: View {
    @State var year: Int?
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("basYear") private var storedYear = Calendar.current.component(.year, from: .now)
    
    private var officerBAS: String {
        BASTables.shared.basTable(for: storedYear)?.officer.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var enlistedBAS: String {
        BASTables.shared.basTable(for: storedYear)?.enlisted.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var basII: String {
        BASTables.shared.basTable(for: storedYear)?.basII.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $storedYear) {
                        ForEach(BASTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    LabeledContent("Officer") {
                        Text(officerBAS)
                            .textSelection(.enabled)
                    }
                    
                    LabeledContent("Enlisted") {
                        Text(enlistedBAS)
                            .textSelection(.enabled)
                    }
                    
                    LabeledContent("BAS II") {
                        Text(basII)
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("BAS Tables")
            .toolbar {
                ToolbarItem {
                    Button("Done", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let year {
                    storedYear = year
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showSheet = true
    
    Button("Show BAS Tables") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        BASTablesSheet()
            .presentationDetents([.medium])
    }
}
