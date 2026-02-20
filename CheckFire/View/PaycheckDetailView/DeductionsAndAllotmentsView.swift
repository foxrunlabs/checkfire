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
                SectionView(category: .deduction, paycheck: paycheck, selectedID: $selectedID)
                SectionView(category: .allotment, paycheck: paycheck, selectedID: $selectedID)
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
                    Button("New Allotment", systemImage: "tray.and.arrow.down") {
                        addLESItem(category: .allotment)
                    }
                    
                    Button("New Deduction", systemImage: "minus.circle") {
                        addLESItem(category: .deduction)
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
        let name = "New " + String(describing: category)
        let newItem = Paycheck.LESItem(name, amount: 0.00, category: category)
        paycheck.lesItems.append(newItem)
        selectedID = newItem.id
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


// MARK: - Section View
fileprivate struct SectionView: View {
    let category: Paycheck.LESItem.Category
    let paycheck: Paycheck
    @Binding var selectedID: Paycheck.LESItem.ID?
    
    // MARK: - Computed Properties
    private var lesItems: [Paycheck.LESItem] {
        paycheck.lesItems.filter { $0.category == category }
    }
    
    // MARK: - Body
    var body: some View {
        Section {
            ForEach(lesItems) { lesItem in
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
        } header: {
            HStack {
                Text(String(describing: category) + "s")
                Spacer()
                Text(lesItems.sum(\.amount), format: .currency(code: "USD"))
            }
        }
        .listRowSeparator(.hidden)
    }
    
    // MARK: - Methods
    private func deleteLESItem(_ lesItem: Paycheck.LESItem) {
        guard let i = paycheck.lesItems.firstIndex(where: { $0.id == lesItem.id }) else { return }
        paycheck.lesItems.remove(at: i)
        selectedID = nil
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        DeductionsAndAllotmentsView(paycheck: .example)
    }
}
