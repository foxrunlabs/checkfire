import SwiftUI

struct BasicPayTablesDetailView: View {
    let year: Int
    
    @AppStorage("payTableSortBy") private var isSortAscending = false
    @AppStorage("payTableFilterBy") private var filterBy = PayGradeCategory.all
    
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
    
    private var yearsOfService: [YearsOfService] {
        let filteredYears = YearsOfService.allCases.filter { $0 != .lessThan4Months }
        
        return if filterBy == .priorEnlisted {
            filteredYears.filter {
                $0 != .lessThanOrEqual2 && $0 != .over2 && $0 != .over3
            }
        } else {
            filteredYears
        }
    }
    
    var body: some View {
        if let _ = BasicPayTables.shared.payTable(for: year) {
            ScrollView(.vertical) {
                Grid {
                    GridRow {
                        // Pay Grades
                        Grid(verticalSpacing: 10) {
                            Text("Pay Grade")
                                .bold()
                            
                            ForEach(payGrades) { grade in
                                Text(String(describing: grade))
                            }
                        }
                        
                        // Pay Data
                        ScrollView(.horizontal) {
                            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                                GridRow {
                                    ForEach(yearsOfService) { serviceYears in
                                        Text(String(describing: serviceYears))
                                            .bold()
                                    }
                                }
                                
                                ForEach(payGrades) { grade in
                                    GridRow {
                                        ForEach(yearsOfService) { serviceYears in
                                            Text(
                                                BasicPayTables.shared.basicPay(
                                                    for: year,
                                                    as: grade,
                                                    with: serviceYears
                                                )?.formatted(.currency(code: "USD")) ?? "-"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if filterBy == .all || filterBy == .enlisted {
                        Divider()
                        
                        Text("E-1 < 4 months: " +
                             (BasicPayTables.shared.basicPay(
                                for: year,
                                as: .e1,
                                with: .lessThan4Months
                             )?.formatted(.currency(code: "USD")) ?? "-")
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .italic()
                    }
                }
            }
            .padding()
            .navigationTitle(String(describing: year) + " Basic Pay")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
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
            }
        } else {
            ContentUnavailableView(
                "No Results",
                systemImage: "exclamationmark.magnifyingglass",
                description: Text("No basic pay data for " + String(describing: year))
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BasicPayTablesDetailView(year: BasicPayTables.shared.years.first!)
    }
}
