import SwiftUI

struct BasicPayTablesListView: View {
    @Binding var selection: PayComponent?
    
    @AppStorage("basicPaySortBy") private var isAscending = false
    
    private var years: [Int] {
        isAscending ? BasicPayTables.shared.years.sorted() : BasicPayTables.shared.years.sorted(by: >)
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(years, id: \.self) { year in
                ListRow(year: year)
                    .tag(PayComponent.basicPay(year))
            }
        }
        .listStyle(.inset)
        .navigationTitle("Basic Pay Tables")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sort", systemImage: "arrow.up.arrow.down") {
                    isAscending.toggle()
                }
            }
        }
    }
    
    private struct ListRow: View {
        let year: Int
        
        var body: some View {
            NavigationLink(value: year) {
                Text(String(describing: year))
                    .font(.headline)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        BasicPayTablesListView(selection: $selectedPayComponent)
    }
}
