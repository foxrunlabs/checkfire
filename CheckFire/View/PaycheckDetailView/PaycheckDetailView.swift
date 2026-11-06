import Charts
import SwiftData
import SwiftUI
import UIKit

struct PaycheckDetailView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(PaySystem.self) private var paySystem
    @Environment(\.modelContext) private var modelContext
    
    @Query private var paychecks: [Paycheck]
    
    // MARK: - Computed Properties
    
    private var paycheckResult: PaySystem.PaycheckResult? {
        try? paySystem.calculate(paycheck)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HeaderView(paycheck: paycheck, years: paySystem.taxYears)
                .padding([.horizontal, .top])
            
            if let paycheckResult {
                SummaryView(paycheckResult: paycheckResult)
                    .padding(.horizontal)
                
                List {
                    ListRow("Entitlements", value: paycheckResult.grossPay, color: .primary) {
                        EntitlementsView(paycheck: paycheck)
                    }
                    
                    ListRow(
                        "Thrift Savings Plan",
                        value: paycheckResult.totalTSP,
                        color: .blue
                    ) {
                        TSPDetailView(paycheck: paycheck)
                    }
                    
                    ListRow(
                        "Federal Taxes",
                        value: paycheckResult.totalTax,
                        color: .red
                    ) {
                        FederalWithholdingView(paycheck: paycheck)
                    }
                    
                    ListRow(
                        "Deductions & Allotments",
                        value: paycheckResult.adjustments,
                        color: .orange
                    ) {
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
        "\(paycheck.date.formatted(.dateTime.month(.abbreviated))) \(paycheck.year)"
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

fileprivate struct SummaryView: View {
    let paycheckResult: PaySystem.PaycheckResult
    
    // MARK: - Computed Properties
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("TSP", paycheckResult.totalTSP),
            ("Taxes", paycheckResult.totalTax),
            ("Other", paycheckResult.adjustments),
            ("Net Pay", paycheckResult.netPay)
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
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
                    
                    Text(paycheckResult.netPay, format: .currency(code: "USD"))
                        .font(.title3)
                        .monospacedDigit()
                        .bold()
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
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
    .environment(PreviewController.paySystem)
    .modelContainer(PreviewController.container)
}
