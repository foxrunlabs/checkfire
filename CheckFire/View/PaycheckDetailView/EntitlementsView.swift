import Charts
import Foundation
import SwiftUI

struct EntitlementsView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var selectedID: Paycheck.LESItem.ID?
    
    // MARK: - Computed Properties
    
    private var showLESItemEditorSheet: Binding<Bool> {
        Binding(
            get: { selectedID != nil },
            set: { isPresented in
                if !isPresented { selectedID = nil }
            }
        )
    }
    
    private var selectionIndex: Int? {
        guard let selectedID else { return nil }
        return paycheck.lesItems.firstIndex { $0.id == selectedID }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            SummaryView(paycheck: paycheck)
                .padding()
            
            Divider()
                .padding(.horizontal)
            
            LabeledCurrencyField("Basic Pay", value: $paycheck.basicPay)
                .padding([.top, .horizontal])
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { dismissKeyboard() }
                    }
                }
                        
            List {
                ForEach(Paycheck.LESItem.Category.entitlementCases) { category in
                    if !paycheck.lesItems(category).isEmpty {
                        SectionView(paycheck: paycheck, category: category, selectedID: $selectedID)
                    }
                }
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
                Menu {
                    ForEach(Paycheck.LESItem.Category.entitlementCases.reversed()) { category in
                        Button(
                            "New \(category.displayName)",
                            systemImage: sfSymbol(for: category)
                        ) {
                            addLESItem(category: category)
                        }
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: showLESItemEditorSheet) {
            if let selectionIndex {
                EditLESItemSheet(lesItem: $paycheck.lesItems[selectionIndex])
                    .presentationDetents([.medium])
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Methods
    
    private func addLESItem(category: Paycheck.LESItem.Category) {
        let name = "New \(category.displayName)"
        let newItem = Paycheck.LESItem(name, amount: 0.00, category: category)
        withAnimation { paycheck.lesItems.append(newItem) }
        selectedID = newItem.id
    }
    
    private func sfSymbol(for category: Paycheck.LESItem.Category) -> String {
        switch category {
        case .allowance:
            "house"
        case .bonusPay:
            "banknote"
        case .incentivePay:
            "bolt"
        case .specialPay:
            "star"
        default:
            ""
        }
    }
}


// MARK: - Summary View

fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    private var totalEntitlements: Decimal {
        paycheck.basicPay + paycheck.entitlements.sum(\.amount)
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
                "Basic Pay",
                value: paycheck.basicPay,
                format: .currency(code: "USD")
            )
            .monospacedDigit()
            .foregroundStyle(.primary)
            
            ForEach(Paycheck.LESItem.Category.entitlementCases) { category in
                if !paycheck.lesItems(category).isEmpty {
                    LabeledContent(
                        "\(category.displayName)s",
                        value: paycheck.lesItems(category).sum(\.amount),
                        format: .currency(code: "USD")
                    )
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                }
            }
            
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


// MARK: - Section View

fileprivate struct SectionView: View {
    let paycheck: Paycheck
    let category: Paycheck.LESItem.Category
    @Binding var selectedID: Paycheck.LESItem.ID?
    
    // MARK: - Body
    var body: some View {
        Section("\(category.displayName)s") {
            ForEach(paycheck.lesItems(category)) { lesItem in
                Button {
                    selectedID = lesItem.id
                } label: {
                    LabeledContent(
                        lesItem.name,
                        value: lesItem.amount,
                        format: .currency(code: "USD")
                    )
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteLESItem(lesItem)
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    // MARK: - Methods
    
    private func deleteLESItem(_ lesItem: Paycheck.LESItem) {
        guard let i = paycheck.lesItems.firstIndex(where: { $0.id == lesItem.id }) else { return }
        withAnimation { _ = paycheck.lesItems.remove(at: i) }
        selectedID = nil
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        EntitlementsView(paycheck: .example)
    }
}
