import Charts
import SwiftData
import SwiftUI
import UIKit

struct PaycheckDetailView: View {
    // MARK: - Properties
    @Bindable var paycheck: Paycheck
    @Binding var selection: DetailSelection?
    
    @Environment(WithholdingTableRepository.self) private var withholdingTables
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    
    // MARK: - Computed Properties
    private var grossPay: Decimal {
        paycheck.basicPay + paycheck.lesItems.filter { $0.isEntitlement }.sum(\.amount)
    }
    
    private var totalTSP: Decimal {
        paycheck.tspContribution(.traditional) + paycheck.tspContribution(.roth)
    }
    
    private var taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)? {
        withholdingTables.table(for: paycheck.year)?.calculateTaxes(for: paycheck)
    }
    
    private var totalWithholding: Decimal {
        guard let taxes else { return 0.00 }
        return taxes.federal + taxes.socialSecurity + taxes.medicare
    }
    
    private var otherOutflows: Decimal {
        paycheck.lesItems.filter { $0.isEntitlement == false }.sum(\.amount)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if let taxes {
                    HeaderView(paycheck: paycheck)
                        .padding(.horizontal)
                    
                    SummaryView(paycheck: paycheck, taxes: taxes) {
                        NetPayView(paycheck: paycheck, taxes: taxes)
                    }
                    .padding(.horizontal)
                    
                    List {
                        ListRow("Entitlements", value: grossPay, color: .primary) {
                            EntitlementsView(paycheck: paycheck)
                        }
                        
                        ListRow("Thrift Savings Plan", value: totalTSP, color: .blue) {
                            TSPDetailView(paycheck: paycheck)
                        }
                        
                        ListRow("Federal Withholding", value: totalWithholding, color: .red) {
                            FederalWithholdingView(paycheck: paycheck, taxes: taxes)
                        }
                        
                        ListRow("Deductions & Allotments", value: otherOutflows, color: .orange) {
                            DeductionsAndAllotmentsView(paycheck: paycheck)
                        }
                    }
                    .listStyle(.plain)
                    .scrollBounceBehavior(.basedOnSize)
                } else {
                    ContentUnavailableView("Missing Tax Data", systemImage: "questionmark.text.page")
                }
            }
            .navigationTitle($paycheck.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: - HeaderView
fileprivate struct HeaderView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    private var payPeriod: String {
        let month = Calendar.current.component(.month, from: paycheck.date)
        let monthSymbol = Calendar.current.shortMonthSymbols[month - 1]
        return "\(monthSymbol) \(paycheck.year)"
    }
    
    private var payGrade: String { "\(paycheck.payGrade) \(paycheck.yearsOfService)" }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(payPeriod).font(.title2).bold()
            Spacer()
            Text(payGrade).font(.title2).bold()
        }
    }
}


// MARK: - Summary View
fileprivate struct SummaryView<Destination: View>: View {
    let paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    let destination: () -> Destination
    
    // MARK: - Computed Properties
    private var chartData: [(category: String, total: Decimal)] {
        let totalTsp = paycheck.tspContribution(.traditional) + paycheck.tspContribution(.roth)
        let totalTax = taxes.federal + taxes.socialSecurity + taxes.medicare
        let other = paycheck.lesItems.filter { $0.isEntitlement == false }.sum(\.amount)
        let netPay = paycheck.netPay(taxes: taxes)
        
        return [
            ("TSP", totalTsp),
            ("Taxes", totalTax),
            ("Other", other),
            ("Net Pay", netPay)
        ]
    }
    
    // MARK: - Body
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Grid {
                    GridRow {
                        Chart(chartData, id: \.category) { item in
                            SectorMark(
                                angle: .value("Total", item.total),
                                innerRadius: .ratio(0.5),
                                angularInset: 0.5
                            )
                            .cornerRadius(3)
                            .foregroundStyle(by: .value("Category", item.category))
                        }
                        .chartLegend(.hidden)
                        .chartForegroundStyleScale(
                            ["TSP": .blue, "Taxes": .red, "Other": .orange, "Net Pay": .green]
                        )
                        .scaledToFit()
                        .padding()
                        
                        VStack(alignment: .leading) {
                            Text("Net Pay")
                                .font(.body.lowercaseSmallCaps())
                            
                            Text(paycheck.netPay(taxes: taxes), format: .currency(code: "USD"))
                                .font(.title3)
                                .monospacedDigit()
                                .bold()
                                .foregroundStyle(.green)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .contentShape(Rectangle())
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}


// MARK: - List Row
fileprivate struct ListRow<Destination: View>: View {
    let title: String
    let value: Decimal
    let color: Color
    let destination: Destination
    
    // MARK: - Initializer
    init(
        _ title: String,
        value: Decimal,
        color: Color,
        @ViewBuilder _ destination: () -> Destination
    ) {
        self.title = title
        self.value = value
        self.color = color
        self.destination = destination()
    }
    
    // MARK: - Body
    var body: some View {
        NavigationLink {
            destination
        } label: {
            LabeledContent {
                Text(value, format: .currency(code: "USD"))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } label: {
                HStack {
                    Circle()
                        .fill(color)
                        .frame(width: 15)
                    
                    Text(title)
                }
            }
            .padding(.vertical)
        }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var selection: DetailSelection?
    
    NavigationStack {
        PaycheckDetailView(paycheck: .example, selection: $selection)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
