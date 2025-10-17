import SwiftUI

struct BAHTablesDetailView: View {
    let year: Int
    
    @AppStorage("bahTableZIPCode") private var zipCode = ""
    @AppStorage("bahTableSortBy") private var isSortAscending = false
    @AppStorage("bahTableFilterBy") private var filterBy = PayGradeCategory.all
    
    private var payGrades: [PayGrade] {
        let filteredGrades = switch filterBy {
        case .all: PayGrade.allCases
        case .officers: PayGrade.officers
        case .priorEnlisted: PayGrade.priorEnlisted
        case .warrants: PayGrade.warrants
        case .enlisted: PayGrade.enlisted
        }
        
        return isSortAscending ? filteredGrades.reversed() : filteredGrades
    }
    
    var body: some View {
        if let mha = BAHTables.shared.mhaName(for: year, in: zipCode) {
            VStack {
                Text(mha)
                    .font(.headline)
                
                Text(String(describing: zipCode))
                    .font(.subheadline)
            }
            .padding(.top)
            
            ScrollView(.vertical) {
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Pay Grade")
                            .bold()
                        
                        Text("No Dependents")
                            .bold()
                        
                        Text("Dependents")
                            .bold()
                    }
                    
                    ForEach(payGrades) { grade in
                        GridRow {
                            Text(String(describing: grade))
                            
                            Text(
                                BAHTables.shared.bah(
                                    for: year,
                                    in: zipCode,
                                    as: grade,
                                    withDependents: false
                                ) ?? 0.00, format: .currency(code: "USD")
                            )
                            
                            Text(
                                BAHTables.shared.bah(
                                    for: year,
                                    in: zipCode,
                                    as: grade,
                                    withDependents: true
                                ) ?? 0.00, format: .currency(code: "USD")
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationTitle(String(describing: year) + " BAH Rates")
            .searchable(text: $zipCode, prompt: "ZIP Code")
            .toolbar {
                Menu("Filter", systemImage: "line.3.horizontal.decrease") {
                    Picker("Filter", selection: $filterBy) {
                        ForEach(PayGradeCategory.allCases) { gradeFilter in
                            Text(String(describing: gradeFilter))
                                .tag(gradeFilter)
                        }
                    }
                }
                
                Button("Sort", systemImage: "arrow.up.arrow.down") {
                    isSortAscending.toggle()
                }
            }
        } else {
            ContentUnavailableView(
                "No Results",
                systemImage: "magnifyingglass",
                description: Text("Enter a ZIP code")
            )
            .searchable(text: $zipCode, prompt: "ZIP Code")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BAHTablesDetailView(year: BAHTables.shared.years.first!)
    }
}
