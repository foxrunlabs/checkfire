import SwiftUI

struct BASTablesDetailView: View {
    let year: Int
    
    init(year: Int) {
        self.year = year
        self.basTable = BASTables.shared.basTable(for: year)
    }
    
    private let basTable: BASTable?
    
    var body: some View {
        if let basTable {
            VStack {
                Grid {
                    GridRow {
                        Text("Officer")
                            .bold()
                        
                        Text("Enlisted")
                            .bold()
                        
                        Text("BAS II")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    
                    GridRow {
                        Text(basTable.officer, format: .currency(code: "USD"))
                        Text(basTable.enlisted, format: .currency(code: "USD"))
                        Text(basTable.basII, format: .currency(code: "USD"))
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(String(describing: year) + " BAS Rates")
        } else {
            ContentUnavailableView(
                "No Results",
                systemImage: "exclamationmark.magnifyingglass",
                description: Text("No BAS data for " + String(describing: year))
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BASTablesDetailView(year: BASTables.shared.years.first!)
    }
}
