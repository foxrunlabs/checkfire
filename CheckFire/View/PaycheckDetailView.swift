import SwiftData
import SwiftUI

struct PaycheckDetailView: View {
    @Bindable private var paycheck: Paycheck
    
    @Environment(\.modelContext) private var modelContext
    @Query private var lesItems: [LESItem]
    @Query(sort: \WithholdingForm.date) private var withholdingForms: [WithholdingForm]
    @Query(sort: \ThriftSavingsPlan.date) private var thriftSavingsPlans: [ThriftSavingsPlan]
    
    @State private var showBasePayResetButton = false
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
        
        let paycheckID = paycheck.persistentModelID
        self._lesItems = Query(
            filter: #Predicate<LESItem> { $0.paycheck?.persistentModelID == paycheckID },
            sort: \LESItem.name
        )
    }
    
    private var availableYearsOfService: [YearsOfService] {
        let year = Calendar.current.component(.year, from: paycheck.date)
        return PayTables.shared.yearsOfServiceAvailable(for: year, as: paycheck.payGrade)
    }
    
    private var computedBasePay: Decimal {
        let year = Calendar.current.component(.year, from: paycheck.date)
        return PayTables.shared.basePay(
            for: year,
            as: paycheck.payGrade,
            with: paycheck.yearsOfService
        ) ?? 0.00
    }
    
    private var entitlements: [LESItem] {
        lesItems.filter {
            if case .entitlement(_) = $0.itemType {
                true
            } else {
                false
            }
        }
    }
    
    private var deductions: [LESItem] {
        lesItems.filter { $0.itemType == .deduction }
    }
    
    private var allotments: [LESItem] {
        lesItems.filter { $0.itemType == .allotment }
    }
    
    var body: some View {
        Form {
            Section {
                MonthYearPicker(
                    "Pay Date",
                    selection: $paycheck.date,
                    in: WithholdingTables.shared.years
                )

                Picker("Pay Grade", selection: $paycheck.payGrade) {
                    ForEach(PayGrade.allCases) { grade in
                        Text(String(describing: grade))
                            .tag(grade)
                    }
                }
                .pickerStyle(.menu)
                
                
                Picker("Years of Service", selection: $paycheck.yearsOfService) {
                   ForEach(availableYearsOfService) { serviceYears in
                       Text(String(describing: serviceYears))
                           .tag(serviceYears)
                   }
                }
                .pickerStyle(.menu)

                LabeledContent {
                    TextField("Base Pay", value: $paycheck.basePay, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    HStack {
                        Text("Base Pay")
                        
                        if showBasePayResetButton {
                            Button {
                                paycheck.basePay = computedBasePay
                                showBasePayResetButton.toggle()
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            
            // Entitlements
            Section {
                ForEach(entitlements) { entitlement in
                    LESItemField(lesItem: entitlement)
                }
                .onDelete(perform: deleteEntitlement)
            } header: {
                HStack {
                    Text("Entitlements")

                    Spacer()

                    Button {
                        addEntitlement()
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
            
            // Deductions
            Section {
                ForEach(deductions) { deduction in
                    LESItemField(lesItem: deduction)
                }
                .onDelete(perform: deleteDeduction)
            } header: {
                HStack {
                    Text("Deductions")

                    Spacer()

                    Button {
                        addDeduction()
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
            
            // Allotments
            Section {
                ForEach(allotments) { allotment in
                    LESItemField(lesItem: allotment)
                }
                .onDelete(perform: deleteAllotment)
            } header: {
                HStack {
                    Text("Allotments")

                    Spacer()

                    Button {
                        addAllotment()
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
        }
        .onChange(of: paycheck.date) {
            updateYearsOfService()
            updateBasePay()
            updateWithholdingAndTSP()
        }
        .onChange(of: paycheck.payGrade) {
            updateYearsOfService()
            updateBasePay()
        }
        .onChange(of: paycheck.yearsOfService) {
            updateBasePay()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    // dismiss the keyboard
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                    
                    if paycheck.basePay != computedBasePay {
                        showBasePayResetButton.toggle()
                    }
                }
            }
        }
    }
    
    private func addEntitlement() {
        let newEntitlement = LESItem(
            name: "New Entitlement",
            amount: 0.00,
            itemType: .entitlement(.specialPay),
            paycheck: paycheck
        )
        
        modelContext.insert(newEntitlement)
    }
    
    private func addDeduction() {
        let newDeduction = LESItem(
            name: "New Deduction",
            amount: 0.00,
            itemType: .deduction,
            paycheck: paycheck
        )
        
        modelContext.insert(newDeduction)
    }
    
    private func addAllotment() {
        let newAllotment = LESItem(
            name: "New Allotment",
            amount: 0.00,
            itemType: .allotment,
            paycheck: paycheck
        )
        
        modelContext.insert(newAllotment)
    }
    
    private func deleteEntitlement(at indices: IndexSet) {
        indices.forEach { modelContext.delete(entitlements[$0]) }
    }
    
    private func deleteDeduction(at indices: IndexSet) {
        indices.forEach { modelContext.delete(deductions[$0]) }
    }
    
    private func deleteAllotment(at indices: IndexSet) {
        indices.forEach { modelContext.delete(allotments[$0]) }
    }
    
    private func updateWithholdingAndTSP() {
        paycheck.withholdingForm = withholdingForms.last { $0.date <= paycheck.date }
        paycheck.thriftSavingsPlan = thriftSavingsPlans.last { $0.date <= paycheck.date }
    }
    
    private func updateBasePay() {
        paycheck.basePay = PayTables.shared.basePay(
            for: Calendar.current.component(.year, from: paycheck.date),
            as: paycheck.payGrade,
            with: paycheck.yearsOfService
        ) ?? paycheck.basePay
    }
    
    private func updateYearsOfService() {
        // check if the current years of service exists for the paygrade, and
        // if it does not, select the first available
        if availableYearsOfService.contains(paycheck.yearsOfService) == false {
            paycheck.yearsOfService = availableYearsOfService.first!
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example

    NavigationStack {
        PaycheckDetailView(for: paycheck)
    }
    .modelContainer(PreviewController.container)
}
