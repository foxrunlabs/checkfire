import Charts
import Foundation
import SwiftUI

struct EntitlementsView: View {
    @Bindable var paycheck: Paycheck
    
    // MARK: - Body
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck)
                .padding(.horizontal)
            
            Divider()
                .padding()
            
            LabeledCurrencyField("Basic Pay", value: $paycheck.basicPay)
                .padding(.horizontal)
                        
            List {
                SectionView(paycheck: paycheck, category: .allowance)
                SectionView(paycheck: paycheck, category: .bonusPay)
                SectionView(paycheck: paycheck, category: .incentivePay)
                SectionView(paycheck: paycheck, category: .specialPay)
            }
            .scrollBounceBehavior(.basedOnSize)
            .listStyle(.plain)
        }
        .navigationTitle("Entitlements")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("Add Entitlement", systemImage: "plus") {
                    
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}


// MARK: - Summary View {
fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    private var totalEntitlements: Decimal {
        paycheck.basicPay + paycheck.lesItems.filter { $0.isEntitlement }.sum(\.amount)
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Basic Pay", paycheck.basicPay),
            ("Allowances", paycheck.lesItems.filter { $0.category == .allowance}.sum(\.amount)),
            ("Bonuses", paycheck.lesItems.filter { $0.category == .bonusPay}.sum(\.amount)),
            ("Incentives", paycheck.lesItems.filter { $0.category == .incentivePay}.sum(\.amount)),
            ("Specials", paycheck.lesItems.filter { $0.category == .specialPay}.sum(\.amount) ),
        ]
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            LabeledContent(
                "Total",
                value: totalEntitlements,
                format: .currency(code: "USD")
            )
            .monospacedDigit()
            .foregroundStyle(.primary)
            .bold()
            
            Chart(chartData, id: \.category) { item in
                BarMark(x: .value("", item.total))
                    .foregroundStyle(by: .value("Category", item.category))
            }
            .chartForegroundStyleScale(
                [
                    "Basic Pay": .green,
                    "Allowances": .yellow,
                    "Bonuses": .blue,
                    "Incentives": .indigo,
                    "Specials": .pink
                ]
            )
            .chartXAxis(.hidden)
            .frame(height: 25)
        }
    }
}


// MARK: - Section View {
fileprivate struct SectionView: View {
    let paycheck: Paycheck
    let category: Paycheck.LESItem.Category
    
    // MARK: - Computed Properties
    private var total: Decimal {
        paycheck.lesItems.filter { $0.category == category }.sum(\.amount)
    }
    
    // MARK: - Body
    var body: some View {
        Section {
            ForEach(paycheck.lesItems.filter { $0.category == category }) { item in
                Button {
                    
                } label: {
                    LabeledContent(item.name, value: item.amount, format: .currency(code: "USD"))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteLESItem(item.id)
                    }
                }
            }
        } header: {
            HStack {
                Text(String(describing: category) + "s")
                Spacer()
                Text(total, format: .currency(code: "USD"))
            }
        }
        .listRowSeparator(.hidden)
    }
    
    // MARK: - Methods
    private func deleteLESItem(_ id: UUID) {
        paycheck.lesItems.removeAll { $0.id == id }
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        EntitlementsView(paycheck: .example)
    }
}
