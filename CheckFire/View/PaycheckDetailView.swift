import SwiftData
import SwiftUI

struct PaycheckDetailView: View {
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
        
        let paycheckID = paycheck.persistentModelID
        self._lesItems = Query(
            filter: #Predicate<LESItem> { $0.paycheck?.persistentModelID == paycheckID },
            sort: \.name
        )
    }
    
    @Bindable private var paycheck: Paycheck
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Query private var lesItems: [LESItem]
    
    @State private var showBasicPayTablesSheet = false
    @State private var showBAHTablesSheet = false
    @State private var showBASTablesSheet = false
    
    private var paycheckYear: Int {
        Calendar.current.component(.year, from: paycheck.date)
    }
    
    private var excludedDates: [Date] {
        paychecks.filter({ $0.id != paycheck.id }).map { $0.date }
    }
    
    private var availableYearsOfService: [YearsOfService] {
        BasicPayTables.shared.yearsOfServiceAvailable(for: paycheckYear, as: paycheck.payGrade)
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
                    in: WithholdingTables.shared.years,
                    excluding: excludedDates
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
            }
            
            Section {
                LabeledContent {
                    TextField("Basic Pay", value: $paycheck.basicPay, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    HStack {
                        Button {
                            showBasicPayTablesSheet.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        
                        Text("Basic Pay")
                    }
                }
                
                LabeledContent {
                    TextField("BAH", value: $paycheck.bah, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    HStack {
                        Button {
                            showBAHTablesSheet.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        
                        Text("BAH")
                    }
                }
                
                LabeledContent {
                    TextField("BAS", value: $paycheck.bas, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    HStack {
                        Button {
                            showBASTablesSheet.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.borderless)
                        
                        Text("BAS")
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
            updateBasicPay()
            updateBAS()
        }
        .onChange(of: paycheck.payGrade) {
            updateYearsOfService()
            updateBasicPay()
            updateBAS()
        }
        .onChange(of: paycheck.yearsOfService) {
            updateBasicPay()
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
                }
            }
        }
        .sheet(isPresented: $showBasicPayTablesSheet) {
            BasicPayTablesSheet(year: paycheckYear, payGrade: paycheck.payGrade)
        }
        .sheet(isPresented: $showBAHTablesSheet) {
            BAHTablesSheet(year: paycheckYear, payGrade: paycheck.payGrade)
        }
        .sheet(isPresented: $showBASTablesSheet) {
            BASTablesSheet(year: paycheckYear)
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
    
    private func updateBasicPay() {
        paycheck.basicPay = BasicPayTables.shared.basicPay(
            for: paycheckYear,
            as: paycheck.payGrade,
            with: paycheck.yearsOfService
        ) ?? paycheck.basicPay
    }
    
    private func updateBAS() {
        paycheck.bas = BASTables.shared.bas(
            for: paycheckYear,
            as: paycheck.payGrade
        ) ?? paycheck.bas
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
