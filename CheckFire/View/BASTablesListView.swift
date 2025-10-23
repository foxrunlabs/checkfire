import SwiftUI

struct BASTablesListView: View {
    @Binding var selection: PayComponent?
    
    @AppStorage("basSortBy") private var isAscending = false
    
    private var years: [Int] {
        isAscending ? BASTables.shared.years.sorted() : BASTables.shared.years.sorted(by: >)
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(years, id: \.self) { year in
                ListRow(year: year)
                    .tag(PayComponent.bas(year))
            }
        }
        .listStyle(.inset)
        .navigationTitle("BAS Tables")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sort", systemImage: "arrow.up.arrow.down") {
                    isAscending.toggle()
                }
            }
        }
    }
}

fileprivate struct ListRow: View {
    let year: Int
    
    var body: some View {
        NavigationLink(value: year) {
            Text(String(describing: year))
                .font(.headline)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedPayComponent: PayComponent?
    
    NavigationStack {
        BASTablesListView(selection: $selectedPayComponent)
    }
}
