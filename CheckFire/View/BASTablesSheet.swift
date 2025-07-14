import SwiftUI

struct BASTablesSheet: View {
    @State private var year: Int
    
    @Environment(\.dismiss) private var dismiss
    
    init(year: Int? = nil) {
        self.year = year ?? BASTables.shared.years.first!
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $year) {
                        ForEach(BASTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    HStack {
                        Text("Category")
                            .bold()
                        
                        Spacer()
                        
                        Text("BAS Rate")
                            .bold()
                    }
                    
                    if let basTable = BASTables.shared.basTable(for: year) {
                        LabeledContent("Officer") {
                            Text(basTable.officer, format: .currency(code: "USD"))
                                .textSelection(.enabled)
                        }
                        
                        LabeledContent("Enlisted") {
                            Text(basTable.enlisted, format: .currency(code: "USD"))
                                .textSelection(.enabled)
                        }
                        
                        LabeledContent("BAS II") {
                            Text(basTable.basII, format: .currency(code: "USD"))
                                .textSelection(.enabled)
                        }
                        
                    } else {
                        Text("No Data")
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
        }
    }
}

// MARK: - Preview
#Preview {
    BASTablesSheet()
}
