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
    
    private var excludedDates: [Date] {
        let paychecksMinusCurrent = paychecks.filter { $0.id != paycheck.id }
        return paychecksMinusCurrent.map { $0.date }
    }
    
    private var availableYearsOfService: [YearsOfService] {
        BasicPayTables.shared.yearsOfServiceAvailable(for: paycheck.year, as: paycheck.payGrade)
    }
    
    private var entitlements: [LESItem] { lesItems.filter({ $0.type.isEntitlement }) }
    private var deductions: [LESItem] { lesItems.filter({ $0.type == .deduction }) }
    private var allotments: [LESItem] { lesItems.filter({ $0.type == .allotment }) }
    
    private enum FocusedField {
        case basicPay
        case bah
        case bas
    }
    
    @FocusState private var focus: FocusedField?
    
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
                LabeledContent("Basic Pay") {
                    TextField("Basic Pay", value: $paycheck.basicPay, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .basicPay)
                }
                
                LabeledContent("BAH") {
                    TextField("BAH", value: $paycheck.bah, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .bah)
                }
                
                LabeledContent("BAS") {
                    TextField("BAS", value: $paycheck.bas, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .bas)
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
                        addNewLESItem(type: .specialPay)
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
                        addNewLESItem(type: .deduction)
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
                        addNewLESItem(type: .allotment)
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
                KeyboardToolbar(focus: focus, paycheck: paycheck)
            }
        }
    }
    
    private func addNewLESItem(type: LESItemType) {
        let name = switch type {
        case .deduction:
            "New Deduction"
        case .allotment:
            "New Allotment"
        default:
            "New Entitlement"
        }
        
        let newLESItem = LESItem(
            name: name,
            amount: 0.00,
            type: type,
            paycheck: paycheck
        )
        
        modelContext.insert(newLESItem)
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
            for: paycheck.year,
            as: paycheck.payGrade,
            with: paycheck.yearsOfService
        ) ?? paycheck.basicPay
    }
    
    private func updateBAS() {
        paycheck.bas = BASTables.shared.bas(
            for: paycheck.year,
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
    
    // MARK: - Keyboard Toolbar
    private struct KeyboardToolbar: View {
        let focus: FocusedField?
        let paycheck: Paycheck
        
        @State private var showZIPCodeAlert = false
        @State private var zipCode = ""
        
        private var bahRates: [Decimal]? {
            guard let withoutDependents = BAHTables.shared.bah(
                for: paycheck.year,
                in: zipCode,
                as: paycheck.payGrade,
                withDependents: false
            ) else { return nil }
            
            guard let withDependents = BAHTables.shared.bah(
                for: paycheck.year,
                in: zipCode,
                as: paycheck.payGrade,
                withDependents: true
            ) else { return nil }
            
            return [withoutDependents, withDependents]
        }
        
        var body: some View {
            HStack {
                switch focus {
                case .basicPay:
                    // Allow user to select basic pay from database
                    if let basicPay = BasicPayTables.shared.basicPay(
                        for: paycheck.year,
                        as: paycheck.payGrade,
                        with: paycheck.yearsOfService
                    ) {
                        Button {
                            paycheck.basicPay = basicPay
                            dismissKeyboard()
                        } label: {
                            VStack {
                                Text(basicPay, format: .currency(code: "USD"))
                                
                                Text(
                                    String(describing: paycheck.payGrade) + " " +
                                    String(describing: paycheck.yearsOfService)
                                )
                                .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                    }
                case .bah:
                    // ZIP code search
                    VStack(spacing: 0) {
                        Button {
                            showZIPCodeAlert.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(zipCode.isEmpty ? nil : .caption)
                        }
                        
                        if !zipCode.isEmpty {
                            Text(zipCode)
                                .font(.caption)
                        }
                    }
                    
                    // Allow user to select BAH rate from database
                    if let bahRates {
                        Divider()
                        
                        Button {
                            paycheck.bah = bahRates[0]
                            dismissKeyboard()
                        } label: {
                            VStack {
                                Text(bahRates[0], format: .currency(code: "USD"))
                                Text("No Dependents")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        Button {
                            paycheck.bah = bahRates[1]
                            dismissKeyboard()
                        } label: {
                            VStack {
                                Text(bahRates[1], format: .currency(code: "USD"))
                                Text("Dependents")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                    } else {
                        Spacer()
                    }
                case .bas:
                    // Allow user to select BAS from database
                    if let basTable = BASTables.shared.basTable(for: paycheck.year) {
                        Button {
                            paycheck.bas = paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer
                            dismissKeyboard()
                        } label: {
                            VStack {
                                Text(
                                    paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer,
                                    format: .currency(code: "USD")
                                )
                                Text(paycheck.payGrade.isEnlisted ? "Enlisted" : "Officer")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        if paycheck.payGrade.isEnlisted {
                            Button {
                                paycheck.bas = basTable.basII
                                dismissKeyboard()
                            } label: {
                                VStack {
                                    Text(basTable.basII, format: .currency(code: "USD"))
                                    Text("BAS II")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                        }
                    }
                case nil:
                    Spacer()
                }
                
                Button("Done") { dismissKeyboard() }
            }
            .alert("Enter ZIP Code", isPresented: $showZIPCodeAlert) {
                TextField("ZIP Code", text: $zipCode)
                    .keyboardType(.numberPad)
                
                Button("OK") {}
                Button("Cancel", role: .cancel) {}
            }
        }
        
        private func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
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
