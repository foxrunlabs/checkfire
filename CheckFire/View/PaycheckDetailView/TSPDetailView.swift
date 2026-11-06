import Charts
import Foundation
import SwiftUI

struct TSPDetailView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(PaySystem.self) private var paySystem
    
    // MARK: - Computed Properties
    
    private var paycheckResult: PaySystem.PaycheckResult? {
        try? paySystem.calculate(paycheck)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if let paycheckResult {
                SummaryView(paycheckResult: paycheckResult)
                    .padding()
                
                Divider()
                    .padding(.horizontal)
                
                List {
                    ForEach(Paycheck.TSPType.allCases) { tspType in
                        SectionView(paycheck: paycheck, type: tspType)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .listStyle(.plain)
            } else {
                ContentUnavailableView("Missing Tax Data", systemImage: "questionmark.text.page")
            }
        }
        .navigationTitle("Thrift Savings Plan")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Summary View

fileprivate struct SummaryView: View {
    let paycheckResult: PaySystem.PaycheckResult
    
    // MARK: - Computed Properties
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Traditional", paycheckResult.traditionalTSP),
            ("Roth", paycheckResult.rothTSP)
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent(
                "Traditional",
                value: paycheckResult.traditionalTSP,
                format: .currency(code: "USD")
            )
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            LabeledContent(
                "Roth",
                value: paycheckResult.rothTSP,
                format: .currency(code: "USD")
            )
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            LabeledContent(
                "Total",
                value: paycheckResult.totalTSP,
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
    
    private var otherPlan: Paycheck.ThriftSavingsPlan {
        type == .traditional ? paycheck.rothTSP : paycheck.traditionalTSP
    }
    
    // MARK: - Body
    
    var body: some View {
        Section(type.displayName) {
            TSPStepper(
                "Basic Pay",
                value: tsp.basicPayRate,
                max: 1 - otherPlan.basicPayRate
            )
            
            TSPStepper(
                "Special Pay",
                value: tsp.specialPayRate,
                max: 1 - otherPlan.specialPayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
            
            TSPStepper(
                "Incentive Pay",
                value: tsp.incentivePayRate,
                max: 1 - otherPlan.incentivePayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
            
            TSPStepper(
                "Bonus Pay",
                value: tsp.bonusPayRate,
                max: 1 - otherPlan.bonusPayRate
            )
            .disabled(tsp.wrappedValue.basicPayRate.isZero)
        }
        .listRowSeparator(.hidden)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        TSPDetailView(paycheck: .example)
    }
    .environment(PreviewController.paySystem)
}

