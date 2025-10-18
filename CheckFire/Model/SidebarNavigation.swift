enum SidebarNavigation: CaseIterable, CustomStringConvertible, Identifiable {
    case paychecks
    case withholdingForms
    case thriftSavingsPlans
    case basicPayTables
    case bahTables
    case basTables
    
    static var payDataCases: [Self] = [.paychecks, .withholdingForms, .thriftSavingsPlans]
    static var tableCases: [Self] = [.basicPayTables, .bahTables, .basTables]
    
    var icon: String {
        switch self {
        case .paychecks: "dollarsign"
        case .withholdingForms: "pencil.and.list.clipboard"
        case .thriftSavingsPlans: "dollarsign.bank.building"
        case .basicPayTables: "tablecells"
        case .bahTables: "house"
        case .basTables: "fork.knife"
        }
    }
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .paychecks: "Paychecks"
        case .withholdingForms: "Withholding Forms"
        case .thriftSavingsPlans: "Thrift Savings Plans"
        case .basicPayTables: "Basic Pay Tables"
        case .bahTables: "BAH Tables"
        case .basTables: "BAS Tables"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
