import Charts
import Foundation
import SwiftUI

struct TSPDetailView: View {
    @Bindable var paycheck: Paycheck
    
    // MARK: - Body
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck)
                .padding()
            
            Divider()
                .padding(.horizontal)
            
            List {
                SectionView(paycheck: paycheck, type: .traditional)
                SectionView(paycheck: paycheck, type: .roth)
            }
            .scrollBounceBehavior(.basedOnSize)
            .listStyle(.plain)
        }
        .navigationTitle("Thrift Savings Plan")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Summary View {
fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    private var maximumContribution: Decimal {
        let eligibleEntitlements = paycheck.lesItems.filter { lesItem in
            lesItem.isEntitlement && lesItem.category != .allowance
        }
        
        return paycheck.basicPay + eligibleEntitlements.sum(\.amount)
    }
    
    private var totalContribution: Decimal {
        paycheck.tspContribution(.traditional) + paycheck.tspContribution(.roth)
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Traditional", paycheck.tspContribution(.traditional)),
            ("Roth", paycheck.tspContribution(.roth))
        ]
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            LabeledContent(
                "Maximum Contribution",
                value: maximumContribution,
                format: .currency(code: "USD")
            )
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            LabeledContent(
                "Total",
                value: totalContribution,
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
                ["Traditional": .blue, "Roth": .orange]
            )
            .chartXAxis(.hidden)
            .frame(height: 25)
        }
    }
}


// MARK: - Section View
fileprivate struct SectionView: View {
    @Bindable var paycheck: Paycheck
    let type: Paycheck.TSPType
    
    // MARK: - Computed Properties
    private var tsp: Binding<Paycheck.ThriftSavingsPlan> {
        type == .traditional ? $paycheck.traditionalTSP : $paycheck.rothTSP
    }
    
    private var total: Decimal { paycheck.tspContribution(type) }
    
    // MARK: - Body
    var body: some View {
        Section {
            TSPStepper(
                "Basic Pay",
                value: tsp.basicPayRate,
                max: 1 - tsp.wrappedValue.basicPayRate
            )
            
            TSPStepper(
                "Special Pay",
                value: tsp.specialPayRate,
                max: 1 - tsp.wrappedValue.specialPayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
            
            TSPStepper(
                "Incentive Pay",
                value: tsp.incentivePayRate,
                max: 1 - tsp.wrappedValue.incentivePayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
            
            TSPStepper(
                "Bonus Pay",
                value: tsp.bonusPayRate,
                max: 1 - tsp.wrappedValue.bonusPayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
        } header: {
            HStack {
                Text(String(describing: type))
                Spacer()
                Text(total, format: .currency(code: "USD"))
            }
        }
        .listRowSeparator(.hidden)
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        TSPDetailView(paycheck: .example)
    }
}

