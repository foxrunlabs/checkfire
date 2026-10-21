import Charts
import Foundation
import SwiftUI

struct FederalWithholdingView: View {
    @Bindable var paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck, taxes: taxes)
                .padding()
            
            Divider()
                .padding(.horizontal)
            
            List {
                DetailView(paycheck: paycheck)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Federal Withholding")
        .navigationSubtitle(paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { dismissKeyboard() }
            }
        }
    }
}


// MARK: - Withholding Summary View

fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    let taxes: (federal: Decimal, socialSecurity: Decimal, medicare: Decimal)
    
    // MARK: - Computed Properties
    private var totalTaxes: Decimal {
        taxes.federal + taxes.socialSecurity + taxes.medicare
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Income Tax", taxes.federal),
            ("Social Security", taxes.socialSecurity),
            ("Medicare", taxes.medicare)
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LabeledContent("Income Tax", value: taxes.federal, format: .currency(code: "USD"))
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
            
            LabeledContent("Total", value: totalTaxes, format: .currency(code: "USD"))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .bold()
            
            Chart(chartData, id: \.category) { item in
                BarMark(x: .value("", item.total))
                    .foregroundStyle(by: .value("Category", item.category))
            }
            .chartForegroundStyleScale(
                ["Income Tax": .blue, "Social Security": .orange, "Medicare": .green]
            )
            .chartXAxis(.hidden)
            .frame(height: 25)
        }
    }
}


// MARK: - Withholding Detail View

fileprivate struct DetailView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var showTip = false
    
    // MARK: - Body
    var body: some View {
        Picker("Filing Status", selection: $paycheck.withholdingForm.maritalStatus.animation()) {
            ForEach(MaritalStatus.allCases) { status in
                Text(status.displayName)
                    .tag(status)
            }
        }
        .pickerStyle(.menu)
        
        Toggle("Two Jobs", isOn: $paycheck.withholdingForm.multipleJobs.animation())
        
        Stepper(
            "^[\(paycheck.withholdingForm.childDependents) Child Dependents](inflect: true)",
            value: $paycheck.withholdingForm.childDependents.animation(),
            in: 0...10
        )
        
        Stepper(
            "^[\(paycheck.withholdingForm.otherDependents) Other Dependents](inflect: true)",
            value: $paycheck.withholdingForm.otherDependents.animation(),
            in: 0...10
        )
        
        LabeledCurrencyField(
            "Other Income",
            value: $paycheck.withholdingForm.otherIncome.animation(),
            tip: """
If you want tax withheld for other income you expect this year that won’t \
have withholding, enter the amount of other income here. This may include \
interest, dividends, and retirement income.
"""
        )
        
        LabeledCurrencyField(
            "Other Deductions",
            value: $paycheck.withholdingForm.deductions.animation(),
            tip: """
If you enter $0.00, your withholding will be based on the standard deduction.
"""
        )
        
        LabeledCurrencyField(
            "Extra Withholding",
            value: $paycheck.withholdingForm.extraWithholding.animation(),
            tip: """
Enter any additional tax you want withheld each month.
"""
        )
    }
}


// MARK: - Preview

#Preview {
    let withholdingTables = WithholdingTableRepository(from: "withholding_tables.json")
    let paycheck: Paycheck = .example
    let taxes = withholdingTables.table(for: paycheck.year)!.calculateTaxes(for: paycheck)!
    
    NavigationStack {
        FederalWithholdingView(paycheck: paycheck, taxes: taxes)
    }
}
