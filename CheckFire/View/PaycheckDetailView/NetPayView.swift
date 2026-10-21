import Charts
import Foundation
import SwiftUI

struct NetPayView: View {
    let paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck, taxes: taxes)
                .padding(.vertical)
            
            Divider()
            
            ScrollView {
                EntitlementsListView(paycheck: paycheck)
                
                Divider()
                    .padding(.vertical)
                
                DeductionsListView(paycheck: paycheck, taxes: taxes)
                
                Divider()
                    .padding(.vertical)
                
                AllotmentsListView(paycheck: paycheck)
            }
            .padding(.top)
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal)
        .navigationTitle("Net Pay")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Take Home Summary View

fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    
    // MARK: - Computed Properties
    private var totalDeductions: Decimal {
        var total = taxes.federal + taxes.socialSecurity + taxes.medicare
        total += paycheck.lesItems.filter { $0.category == .deduction }.sum(\.amount)
        total += paycheck.tspContribution(.traditional) + paycheck.tspContribution(.roth)
        return total
    }
    
    private var totalAllotments: Decimal {
        paycheck.lesItems.filter { $0.category == .allotment }.sum(\.amount)
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Deductions", totalDeductions),
            ("Allotments", totalAllotments),
            ("Net Pay", paycheck.netPay(taxes: taxes))
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent("Total", value: paycheck.netPay(taxes: taxes), format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .bold()
            
            Chart(chartData, id: \.category) { item in
                BarMark(x: .value("", item.total))
                    .foregroundStyle(by: .value("Category", item.category))
            }
            .chartForegroundStyleScale(
                ["Deductions": .blue, "Allotments": .orange, "Net Pay": .green]
            )
            .chartXAxis(.hidden)
            .frame(height: 25)
        }
    }
}


// MARK: - Entitlements View

fileprivate struct EntitlementsListView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    
    private var entitlements: [Paycheck.LESItem] {
        paycheck.lesItems.filter { $0.isEntitlement }.sorted { $1.name > $0.name }
    }
    
    private var totalEntitlements: Decimal {
        paycheck.basicPay + entitlements.sum(\.amount)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent("Entitlements", value: totalEntitlements, format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .bold()
            
            LabeledContent("Basic Pay", value: paycheck.basicPay, format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
            
            ForEach(entitlements) { entitlement in
                LabeledContent(entitlement.name, value: entitlement.amount, format: .currency(code: "USD"))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
    }
}


// MARK: - Deductions View

fileprivate struct DeductionsListView: View {
    let paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    
    // MARK: - Computed Properties
    
    private var deductions: [Paycheck.LESItem] {
        paycheck.lesItems.filter { $0.category == .deduction }
    }
    
    private var totalDeductions: Decimal {
        var total = taxes.federal + taxes.socialSecurity + taxes.medicare
        total += paycheck.tspContribution(.traditional) + paycheck.tspContribution(.roth)
        total += deductions.sum(\.amount)
        return total
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent("Deductions", value: totalDeductions, format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .bold()
            
            LabeledContent("Federal Income Tax", value: taxes.federal, format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
            
            LabeledContent {
                Text(taxes.socialSecurity, format: .currency(code: "USD"))
            } label: {
                HStack {
                    Text("Social Security")
                    TipButton("""
                        Social Security estimate is based on monthly pay only and does not \
                        consider the annual wage limit.
                        """,
                        systemName: "info.circle"
                    )
                }
            }
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            LabeledContent {
                Text(taxes.medicare, format: .currency(code: "USD"))
            } label: {
                HStack {
                    Text("Medicare")
                    TipButton("""
                        Medicare estimate is based on monthly pay only and does not \
                        compute additional medicare withholding for higher incomes.
                        """,
                        systemName: "info.circle"
                    )
                }
            }
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            ForEach(deductions) { deduction in
                LabeledContent(deduction.name, value: deduction.amount, format: .currency(code: "USD"))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
            
            ForEach(Paycheck.TSPType.allCases) { tspType in
                if paycheck.tspContribution(tspType) > 0.00 {
                    LabeledContent(
                        "\(tspType.displayName) TSP",
                        value: paycheck.tspContribution(tspType),
                        format: .currency(code: "USD")
                    )
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                }
            }
        }
    }
}


// MARK: Allotments View

fileprivate struct AllotmentsListView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    
    private var allotments: [Paycheck.LESItem] {
        paycheck.lesItems.filter { $0.category == .allotment }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent("Allotments", value: allotments.sum(\.amount), format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .bold()
            
            ForEach(allotments) { allotment in
                LabeledContent(allotment.name, value: allotment.amount, format: .currency(code: "USD"))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
    }
}


// MARK: - Preview

#Preview {
    let withholdingTables = WithholdingTableRepository(from: "withholding_tables.json")
    let paycheck: Paycheck = .example
    let taxes = withholdingTables.table(for: paycheck.year)!.calculateTaxes(for: paycheck)!
    
    NavigationStack {
        NetPayView(paycheck: paycheck, taxes: taxes)
    }
}
