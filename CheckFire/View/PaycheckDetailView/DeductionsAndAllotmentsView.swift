import Charts
import Foundation
import SwiftUI

struct DeductionsAndAllotmentsView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var selectedID: Paycheck.LESItem.ID?
    
    // MARK: - Computed Properties
    
    private var showSheet: Binding<Bool> {
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
            
            List {
                ForEach(Paycheck.LESItem.Category.adjustmentCases) { category in
                    if !paycheck.lesItems(category).isEmpty {
                        SectionView(paycheck: paycheck, category: category, selectedID: $selectedID)
                    }
                }
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
                Menu {
                    ForEach(Paycheck.LESItem.Category.adjustmentCases.reversed()) { category in
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
        .sheet(isPresented: showSheet) {
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
        case .deduction:
            "minus.circle"
        case .allotment:
            "tray.and.arrow.down"
        default:
            ""
        }
    }
}


// MARK: - Summary View

fileprivate struct SummaryView: View {
    let paycheck: Paycheck
    
    // MARK: - Computed Properties
    
    private var totalAdjustments: Decimal {
        paycheck.adjustments.sum(\.amount)
    }
    
    private var chartData: [(category: String, total: Decimal)] {
        [
            ("Deductions", paycheck.lesItems(.deduction).sum(\.amount)),
            ("Allotments", paycheck.lesItems(.allotment).sum(\.amount)),
        ]
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ForEach(Paycheck.LESItem.Category.adjustmentCases) { category in
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
                value: totalAdjustments,
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
        withAnimation { paycheck.lesItems.remove(at: i) }
        selectedID = nil
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        DeductionsAndAllotmentsView(paycheck: .example)
    }
}
