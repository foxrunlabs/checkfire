import SwiftData
import SwiftUI
import UIKit

struct PaycheckDetailView: View {
    private enum FocusedField: Hashable {
        case basicPay
        case lesAmount(UUID)
        
    }
    
    // MARK: - Properties
    @Bindable var paycheck: Paycheck
    
    @Environment(WithholdingTableRepository.self) private var withholdingTables
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @FocusState private var focus: FocusedField?
    
    // MARK: - Computed Properties
    private var entitlementIndices: [Int] {
        paycheck.lesItems.indices.filter { paycheck.lesItems[$0].isEntitlement }
    }
    
    private var deductionIndices: [Int] {
        paycheck.lesItems.indices.filter { paycheck.lesItems[$0].category == .deduction }
    }
    
    private var allotmentIndices: [Int] {
        paycheck.lesItems.indices.filter { paycheck.lesItems[$0].category == .allotment }
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            Section {
                LabeledContent("Pay Date") {
                    MonthYearPicker(selection: $paycheck.date, in: withholdingTables.years)
                }
                
                Picker("Pay Grade", selection: $paycheck.payGrade) {
                    ForEach(Paycheck.PayGrade.allCases) { payGrade in
                        Text(String(describing: payGrade))
                            .tag(payGrade)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Years of Service", selection: $paycheck.yearsOfService) {
                    ForEach(Paycheck.YearsOfService.allCases) { yearsOfService in
                        Text(String(describing: yearsOfService))
                            .tag(yearsOfService)
                    }
                }
                .pickerStyle(.menu)
                
                LabeledCurrencyField("Basic Pay", value: $paycheck.basicPay)
                    .focused($focus, equals: .basicPay)
            }
            
            // Entitlements
            Section {
                ForEach(entitlementIndices, id: \.self) { index in
                    LESItemField(lesItem: $paycheck.lesItems[index], focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(at: index)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Entitlements") {
                    addLESItem(category: .specialPay)
                }
            }
            
            // Deductions
            Section {
                ForEach(deductionIndices, id: \.self) { index in
                    LESItemField(lesItem: $paycheck.lesItems[index], focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(at: index)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Deductions") {
                    addLESItem(category: .deduction)
                }
            }
            
            // Allotments
            Section {
                ForEach(allotmentIndices, id: \.self) { index in
                    LESItemField(lesItem: $paycheck.lesItems[index], focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(at: index)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Allotments") {
                    addLESItem(category: .allotment)
                }
            }
            
            // Withholding Form
            Section("Withholding Form") {
                Picker("Marital Status", selection: $paycheck.withholdingForm.maritalStatus) {
                    ForEach(MaritalStatus.allCases) { status in
                        Text(String(describing: status))
                            .tag(status)
                    }
                }
                .pickerStyle(.menu)

                Toggle(
                    "Multiple Jobs or Spouse Works",
                    isOn: $paycheck.withholdingForm.multipleJobs
                )
                
                Stepper(
                    "^[\(paycheck.withholdingForm.childDependents) Additional Dependents](inflect: true) Under 17",
                    value: $paycheck.withholdingForm.childDependents,
                    in: 0...10
                )

                Stepper(
                    "^[\(paycheck.withholdingForm.otherDependents) Other Dependents](inflect: true)",
                    value: $paycheck.withholdingForm.otherDependents,
                    in: 0...10
                )
                
                LabeledCurrencyField(
                    "Other Income Amount - Not From Jobs",
                    value: $paycheck.withholdingForm.otherIncome
                )

                LabeledCurrencyField(
                    "Other Deductions",
                    value: $paycheck.withholdingForm.deductions
                )

                LabeledCurrencyField(
                    "Extra Withholding Amount Monthly",
                    value: $paycheck.withholdingForm.extraWithholding
                )
            }
            
            // Thrift Savings Plan
            Section("Traditional TSP") {
                TSPStepper(
                    "Basic Pay",
                    value: $paycheck.traditionalTSP.basicPayRate,
                    max: 1 - paycheck.rothTSP.basicPayRate
                )

                TSPStepper(
                    "Special Pay",
                    value: $paycheck.traditionalTSP.specialPayRate,
                    max: 1 - paycheck.rothTSP.specialPayRate
                )
                .disabled(paycheck.traditionalTSP.basicPayRate.isZero)

                TSPStepper(
                    "Incentive Pay",
                    value: $paycheck.traditionalTSP.incentivePayRate,
                    max: 1 - paycheck.rothTSP.incentivePayRate
                )
                .disabled(paycheck.traditionalTSP.basicPayRate.isZero)

                TSPStepper(
                    "Bonus Pay",
                    value: $paycheck.traditionalTSP.bonusPayRate,
                    max: 1 - paycheck.rothTSP.bonusPayRate
                )
                .disabled(paycheck.traditionalTSP.basicPayRate.isZero)
            }

            Section("Roth TSP") {
                TSPStepper(
                    "Basic Pay",
                    value: $paycheck.rothTSP.basicPayRate,
                    max: 1 - paycheck.traditionalTSP.basicPayRate
                )

                TSPStepper(
                    "Special Pay",
                    value: $paycheck.rothTSP.specialPayRate,
                    max: 1 - paycheck.traditionalTSP.specialPayRate
                )
                .disabled(paycheck.rothTSP.basicPayRate.isZero)

                TSPStepper(
                    "Incentive Pay",
                    value: $paycheck.rothTSP.incentivePayRate,
                    max: 1 - paycheck.traditionalTSP.incentivePayRate
                )
                .disabled(paycheck.rothTSP.basicPayRate.isZero)

                TSPStepper(
                    "Bonus Pay",
                    value: $paycheck.rothTSP.bonusPayRate,
                    max: 1 - paycheck.traditionalTSP.bonusPayRate
                )
                .disabled(paycheck.rothTSP.basicPayRate.isZero)
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                switch focus {
                case .basicPay, .lesAmount:
                    HStack {
                        Spacer()
                        Button("Done") { dismissKeyboard() }
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Methods
    private func addLESItem(category: Paycheck.LESItem.Category) {
        let name = switch category {
        case .deduction:
            "New Deduction"
        case .allotment:
            "New Allotment"
        default:
            "New Entitlement"
        }
        
        let newLESItem = Paycheck.LESItem(name, amount: 0.00, category: category)
        paycheck.lesItems.append(newLESItem)
    }
    
    private func deleteLESItem(at index: Int) {
        paycheck.lesItems.remove(at: index)
    }
}


// MARK: - LES Item Section Header
extension PaycheckDetailView {
    private struct LESItemsSectionHeader: View {
        let title: LocalizedStringKey
        let action: @MainActor () -> Void
        
        @Environment(\.modelContext) private var modelContext
        
        // MARK: - Initializers
        init(_ title: LocalizedStringKey, action: @escaping @MainActor () -> Void) {
            self.title = title
            self.action = action
        }
        
        // MARK: - Body
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Button {
                    action()
                } label: {
                    Image(systemName: "plus")
                        .font(.body.smallCaps())
                }
            }
        }
    }
}


// MARK: - LES Item Field
extension PaycheckDetailView {
    private struct LESItemField: View {
        @Binding var lesItem: Paycheck.LESItem
        @FocusState var focus: FocusedField?
        
        // MARK: - Body
        var body: some View {
            LabeledContent {
                CurrencyField(lesItem.name, value: $lesItem.amount)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focus, equals: .lesAmount(lesItem.id))
            } label: {
                HStack {
                    if lesItem.isEntitlement {
                        Menu {
                            Picker("Entitlement Type", selection: $lesItem.category) {
                                ForEach(Paycheck.LESItem.Category.entitlementCases) { entitlement in
                                    LabeledContent(String(describing: entitlement)) {
                                        Image(systemName: icon(for: entitlement))
                                    }
                                    .tag(entitlement)
                                }
                            }
                            .pickerStyle(.inline)
                        } label: {
                            Image(systemName: icon(for: lesItem.category))
                        }
                    }
                    
                    TextField("Item Name", text: $lesItem.name)
                }
            }
        }
        
        // MARK: - Methods
        private func icon(for entitlement: Paycheck.LESItem.Category) -> String {
            switch entitlement {
            case .specialPay:
                "s.square"
            case .incentivePay:
                "i.square"
            case .bonusPay:
                "b.square"
            case .allowance:
                "a.square"
            default:
                ""
            }
        }
    }
}


// MARK: - TSP Stepper
extension PaycheckDetailView {
    private struct TSPStepper: View {
        let title: LocalizedStringKey
        @Binding var value: Decimal
        let max: Decimal
        
        init(_ title: LocalizedStringKey, value: Binding<Decimal>, max: Decimal) {
            self.title = title
            self._value = value
            self.max = max
        }
        
        var body: some View {
            Stepper(
                value: $value,
                in: 0.00...max,
                step: 0.01
            ) {
                HStack {
                    Text(title)
                    Spacer()
                    Text(value, format: .percent)
                }
            }
        }
    }
}


// MARK: - Dismiss Keyboard
fileprivate func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}


// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example

    NavigationStack {
        PaycheckDetailView(paycheck: paycheck)
            .navigationTitle($paycheck.name)
            .navigationBarTitleDisplayMode(.inline)
    }
    .environment(WithholdingTableRepository(from: "withholding_tables.json"))
    .modelContainer(PreviewController.container)
}
