import SwiftData
import SwiftUI

fileprivate enum FocusedField {
    case basicPay
    case bah
    case bas
    case lesItem
}

struct PaycheckDetailView: View {
    @Bindable var paycheck: Paycheck
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
        
        // find LES items associated with this paycheck
        let paycheckID = paycheck.persistentModelID
        self._lesItems = Query(
            filter: #Predicate<LESItem> { $0.paycheck?.persistentModelID == paycheckID },
            sort: \.name
        )
    }
    
    @Environment(\.modelContext) private var modelContext
    @Query private var paychecks: [Paycheck]
    @Query private var lesItems: [LESItem]
    
    @FocusState private var focus: FocusedField?
    
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
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Pay Date") {
                    MonthYearPicker(
                        selection: $paycheck.date,
                        in: WithholdingTables.shared.years,
                        excluding: excludedDates
                    )
                }
                
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
                
                
                LabeledContent("VHA ZIP Code") {
                    TextField("VHA ZIP Code", text: $paycheck.vhaZIP)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .lesItem)
                }
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
                    LESItemField(lesItem: entitlement, focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(entitlement)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Entitlements") {
                    addNewLESItem(type: .specialPay)
                }
            }
            
            // Deductions
            Section {
                ForEach(deductions) { deduction in
                    LESItemField(lesItem: deduction, focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(deduction)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Deductions") {
                    addNewLESItem(type: .deduction)
                }
            }
            
            // Allotments
            Section {
                ForEach(allotments) { allotment in
                    LESItemField(lesItem: allotment, focus: _focus)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteLESItem(allotment)
                            }
                        }
                }
            } header: {
                LESItemsSectionHeader("Allotments") {
                    addNewLESItem(type: .allotment)
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
            ToolbarItem(placement: .keyboard) {
                switch focus {
                case .basicPay:
                    BasicPayKeypadToolbar(paycheck: paycheck)
                case .bah:
                    BAHKeypadToolbar(paycheck: paycheck)
                case .bas:
                    BASKeypadToolbar(paycheck: paycheck)
                case .lesItem:
                    LESItemKeypadToolbar()
                default:
                    EmptyView()
                }
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
    
    private func deleteLESItem(_ item: LESItem) {
        modelContext.delete(item)
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
}

fileprivate struct LESItemsSectionHeader: View {
    let title: any StringProtocol
    let action: @MainActor () -> Void
    
    init<S>(_ title: S, action: @escaping @MainActor () -> Void) where S: StringProtocol {
        self.title = title
        self.action = action
    }
    
    @Environment(\.modelContext) private var modelContext
    
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

fileprivate struct LESItemField: View {
    @Bindable var lesItem: LESItem
    @FocusState var focus: FocusedField?
    
    var body: some View {
        LabeledContent {
            TextField(lesItem.name, value: $lesItem.amount, format: .currency(code: "USD"))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .focused($focus, equals: .lesItem)
        } label: {
            HStack {
                if lesItem.type.isEntitlement {
                    Menu {
                        Picker("Entitlement Type", selection: $lesItem.type) {
                            ForEach(LESItemType.entitlementCases) { entitlement in
                                LabeledContent(String(describing: entitlement)) {
                                    Image(systemName: icon(for: entitlement))
                                }
                                .tag(entitlement)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: icon(for: lesItem.type))
                    }
                }
                
                TextField("Item Name", text: $lesItem.name)
            }
        }
    }
    
    private func icon(for entitlement: LESItemType) -> String {
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

fileprivate struct BasicPayKeypadToolbar: View {
    let paycheck: Paycheck
    
    var body: some View {
        HStack {
            // Allow user to select basic pay from database
            if let basicPay = BasicPayTables.shared.basicPay(
                for: paycheck.year,
                as: paycheck.payGrade,
                with: paycheck.yearsOfService
            ) {
                ToolbarButton(
                    String(describing: paycheck.payGrade) +
                        " " + String(describing: paycheck.yearsOfService),
                    value: basicPay
                ) {
                    paycheck.basicPay = basicPay
                    dismissKeyboard()
                }
                
                Divider()
            } else {
                Spacer()
            }
            
            Button("Done") { dismissKeyboard() }
        }
    }
}

fileprivate struct BAHKeypadToolbar: View {
    let paycheck: Paycheck
    
    private var bahNoDependents: Decimal? {
        BAHTables.shared.bah(
            for: paycheck.year,
            in: paycheck.vhaZIP,
            as: paycheck.payGrade,
            withDependents: false
        )
    }
    
    private var bahDependents: Decimal? {
        BAHTables.shared.bah(
            for: paycheck.year,
            in: paycheck.vhaZIP,
            as: paycheck.payGrade,
            withDependents: true
        )
    }
    
    var body: some View {
        HStack {
            // Allow user to select BAH rate from database
            if let bahNoDependents, let bahDependents {
                ToolbarButton("No Dependents", value: bahNoDependents) {
                    paycheck.bah = bahNoDependents
                    dismissKeyboard()
                }
                
                Divider()
                
                ToolbarButton("Dependents", value: bahDependents) {
                    paycheck.bah = bahDependents
                    dismissKeyboard()
                }
                
                Divider()
            } else {
                Spacer()
            }
            
            Button("Done") { dismissKeyboard() }
        }
    }
}

fileprivate struct BASKeypadToolbar: View {
    let paycheck: Paycheck
    
    var body: some View {
        HStack {
            // Allow user to select BAS from database
            if let basTable = BASTables.shared.basTable(for: paycheck.year) {
                ToolbarButton(
                    paycheck.payGrade.isEnlisted ? "Enlisted" : "Officer",
                    value: paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer
                ) {
                    paycheck.bas = paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer
                    dismissKeyboard()
                }
                
                Divider()
                
                if paycheck.payGrade.isEnlisted {
                    ToolbarButton("BAS II", value: basTable.basII) {
                        paycheck.bas = basTable.basII
                        dismissKeyboard()
                    }
                    
                    Divider()
                }
            } else {
                Spacer()
            }
            
            Button("Done") { dismissKeyboard() }
        }
    }
}

fileprivate struct LESItemKeypadToolbar: View {
    var body: some View {
        HStack {
            Spacer()
            Button("Done") { dismissKeyboard() }
        }
    }
}

fileprivate struct DecimalPadToolbar: View {
    @FocusState var focus: FocusedField?
    let paycheck: Paycheck
    
    @State private var zipCode = ""
    @State private var showZIPCodeAlert = false
    
    private var bahNoDependents: Decimal? {
        BAHTables.shared.bah(
            for: paycheck.year,
            in: zipCode,
            as: paycheck.payGrade,
            withDependents: false
        )
    }
    
    private var bahDependents: Decimal? {
        BAHTables.shared.bah(
            for: paycheck.year,
            in: zipCode,
            as: paycheck.payGrade,
            withDependents: true
        )
    }
        
    var body: some View {
        Group {
            switch focus {
            case .basicPay:
                HStack {
                    // Allow user to select basic pay from database
                    if let basicPay = BasicPayTables.shared.basicPay(
                        for: paycheck.year,
                        as: paycheck.payGrade,
                        with: paycheck.yearsOfService
                    ) {
                        ToolbarButton(
                            String(describing: paycheck.payGrade) +
                            " " + String(describing: paycheck.yearsOfService),
                            value: basicPay
                        ) {
                            paycheck.basicPay = basicPay
                            dismissKeyboard()
                        }
                        
                        Divider()
                    }
                    
                    Button("Done") { dismissKeyboard() }
                }
            case .bah:
                HStack {
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
                    if let bahNoDependents, let bahDependents {
                        Divider()
                        
                        ToolbarButton("No Dependents", value: bahNoDependents) {
                            paycheck.bah = bahNoDependents
                            dismissKeyboard()
                        }
                        
                        Divider()
                        
                        ToolbarButton("Dependents", value: bahDependents) {
                            paycheck.bah = bahDependents
                            dismissKeyboard()
                        }
                        
                        Divider()
                    } else {
                        Spacer()
                    }
                    
                    Button("Done") { dismissKeyboard() }
                }
            case .bas:
                HStack {
                    // Allow user to select BAS from database
                    if let basTable = BASTables.shared.basTable(for: paycheck.year) {
                        ToolbarButton(
                            paycheck.payGrade.isEnlisted ? "Enlisted" : "Officer",
                            value: paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer
                        ) {
                            paycheck.bas = paycheck.payGrade.isEnlisted ? basTable.enlisted : basTable.officer
                            dismissKeyboard()
                        }
                        
                        Divider()
                        
                        if paycheck.payGrade.isEnlisted {
                            ToolbarButton("BAS II", value: basTable.basII) {
                                paycheck.bas = basTable.basII
                                dismissKeyboard()
                            }
                            
                            Divider()
                        }
                    }
                    
                    Button("Done") { dismissKeyboard() }
                }
            case .lesItem:
                HStack {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                }
            case .none:
                HStack {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                }
            }
        }
        .alert("Enter ZIP Code", isPresented: $showZIPCodeAlert) {
            TextField("ZIP Code", text: $zipCode)
                .keyboardType(.numberPad)
                .focused($focus, equals: .lesItem)
            
            Button("OK") {}
            Button("Cancel", role: .cancel) {}
        }
    }
}

fileprivate struct ToolbarButton: View {
    let title: any StringProtocol
    let value: Decimal
    let action: @MainActor () -> Void
    
    init<S>(
        _ title: S,
        value: Decimal,
        action: @escaping @MainActor () -> Void
    ) where S: StringProtocol {
        self.title = title
        self.value = value
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(value, format: .currency(code: "USD"))
                
                Text(title)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

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
        PaycheckDetailView(for: paycheck)
            .navigationTitle($paycheck.name)
            .navigationBarTitleDisplayMode(.inline)
    }
    .modelContainer(PreviewController.container)
}
