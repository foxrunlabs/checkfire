import SwiftData
import SwiftUI

struct PaycheckDetailView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(\.modelContext) private var modelContext
    @Query private var lesItems: [LESItem]
    
    init(paycheck: Paycheck) {
        self.paycheck = paycheck
        
        let paycheckID = paycheck.persistentModelID
        self._lesItems = Query(
            filter: #Predicate<LESItem> { lesItem in
                lesItem.paycheck?.persistentModelID == paycheckID
            }
        )
    }
    
    private var yearsOfService: [YearsOfService] {
        PayTables.shared.yearsOfServiceAvailable(
            for: Calendar.current.component(.year, from: paycheck.date),
            as: paycheck.payGrade
        )
    }
    
    private var entitlements: [LESItem] {
        lesItems.filter {
            if case .entitlement(_) = $0.itemType {
                true
            } else {
                false
            }
        }
        .sorted(by: { $0.name < $1.name })
    }
    
    private var deductions: [LESItem] {
        lesItems.filter {
            $0.itemType == .deduction
        }.sorted(by: { $0.name < $1.name })
    }
    
    private var allotments: [LESItem] {
        lesItems.filter {
            $0.itemType == .allotment
        }.sorted(by: { $0.name < $1.name })
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
                
                if yearsOfService.isEmpty {
                    LabeledContent("Years of Service") {
                       Text("No Data")
                    }
                } else {
                    Picker("Years of Service", selection: $paycheck.yearsOfService) {
                       ForEach(yearsOfService) { serviceYears in
                           Text(String(describing: serviceYears))
                               .tag(serviceYears)
                       }
                   }
                   .pickerStyle(.menu)
                }
                
                LabeledContent {
                    TextField("Base Pay", value: $paycheck.basePay, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                        Text("Base Pay")
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
            paycheck.basePay = PayTables.shared.basePay(for: paycheck) ?? paycheck.basePay
        }
        .onChange(of: paycheck.payGrade) {
            // check if the current years of service exists for the paygrade, and
            // if it does not, select the first available
            if !yearsOfService.contains(paycheck.yearsOfService) {
                paycheck.yearsOfService = yearsOfService.first!
            }
            
            paycheck.basePay = PayTables.shared.basePay(for: paycheck) ?? paycheck.basePay
        }
        .onChange(of: paycheck.yearsOfService) {
            paycheck.basePay = PayTables.shared.basePay(for: paycheck) ?? paycheck.basePay
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
        indices.forEach { index in
            modelContext.delete(entitlements[index])
        }
    }
    
    private func deleteDeduction(at indices: IndexSet) {
        indices.forEach { index in
            modelContext.delete(deductions[index])
        }
    }
    
    private func deleteAllotment(at indices: IndexSet) {
        indices.forEach { index in
            modelContext.delete(allotments[index])
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example

    NavigationStack {
        PaycheckDetailView(paycheck: paycheck)
    }
    .modelContainer(PreviewController.container)
}
