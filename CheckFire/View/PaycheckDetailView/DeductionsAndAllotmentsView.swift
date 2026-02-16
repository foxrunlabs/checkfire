import Charts
import Foundation
import SwiftUI

struct DeductionsAndAllotmentsView: View {
    @Bindable var paycheck: Paycheck
    
    // MARK: - Body
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck)
                .padding(.horizontal)
            
            Divider()
                .padding([.horizontal, .top])
            
            List {
                SectionView(paycheck: paycheck, category: .deduction)
                SectionView(paycheck: paycheck, category: .allotment)
            }
            .scrollBounceBehavior(.basedOnSize)
            .listStyle(.plain)
        }
        .navigationTitle("Deductions & Allotments")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button("Add Deduction or Allotment", systemImage: "plus") {
                    
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}


// MARK: - Summary View
fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    private var totalDeductions: Decimal {
        paycheck.lesItems.filter { $0.category == .deduction }.sum(\.amount)
    }
    
    private var totalAllotments: Decimal {
        paycheck.lesItems.filter { $0.category == .allotment }.sum(\.amount)
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Deductions", paycheck.lesItems.filter { $0.category == .deduction}.sum(\.amount)),
            ("Allotments", paycheck.lesItems.filter { $0.category == .allotment}.sum(\.amount)),
        ]
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            LabeledContent(
                "Total",
                value: totalDeductions + totalAllotments,
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
                    "Deductions": .red,
                    "Allotments": .yellow,
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
            ForEach(paycheck.lesItems.filter { $0.category == category}) { item in
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
        DeductionsAndAllotmentsView(paycheck: .example)
    }
}
