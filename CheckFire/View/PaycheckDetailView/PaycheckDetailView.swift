import Charts
import SwiftData
import SwiftUI
import UIKit

struct PaycheckDetailView: View {
    @Bindable var paycheck: Paycheck
    
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
        VStack {
            HeaderView(paycheck: paycheck, years: withholdingTables.years)
                .padding([.horizontal, .top])
            
            if let taxes {
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


// MARK: - Header View

fileprivate struct HeaderView: View {
    @Bindable var paycheck: Paycheck
    let years: ClosedRange<Int>
    
    @State private var showSheet = false
    
    // MARK: - Computed Properties
    
    private var payPeriod: String {
        let month = Calendar.current.component(.month, from: paycheck.date)
        let monthSymbol = Calendar.current.shortMonthSymbols[month - 1]
        return "\(monthSymbol) \(paycheck.year)"
    }
    
    private var payGrade: String { "\(paycheck.payGrade.displayName) \(paycheck.yearsOfService.displayName)" }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            MonthYearPicker(selection: $paycheck.date, in: years) {
                HStack {
                    Text(payPeriod)
                        .font(.title2)
                        .bold()
                    
                    Image(systemName: "chevron.down")
                }
            }
            
            Spacer()
            
            Button {
                showSheet.toggle()
            } label: {
                HStack {
                    Image(systemName: "chevron.down")
                    Text(payGrade)
                        .font(.title2)
                        .bold()
                }
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showSheet) {
            GradeAndYearsOfServiceSheet(paycheck: paycheck)
                .presentationDetents([.medium])
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

fileprivate struct GradeAndYearsOfServiceSheet: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack {
                        Text("Pay Grade")
                            .font(.title2)
                            .bold()
                        
                        Picker("Pay Grade", selection: $paycheck.payGrade) {
                            ForEach(Paycheck.PayGrade.allCases) { payGrade in
                                Text(payGrade.displayName)
                                    .tag(payGrade)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    
                    VStack {
                        Text("Years of Service")
                            .font(.title2)
                            .bold()
                        
                        Picker("Years of Service", selection: $paycheck.yearsOfService) {
                            ForEach(Paycheck.YearsOfService.allCases) { serviceYears in
                                Text(serviceYears.displayName)
                                    .tag(serviceYears)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark", role: .confirm) { dismiss() }
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        PaycheckDetailView(paycheck: .example)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
