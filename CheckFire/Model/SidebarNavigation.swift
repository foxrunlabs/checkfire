enum SidebarNavigation: CaseIterable, CustomStringConvertible, Identifiable {
    case paychecks
    case withholdingForms
    case thriftSavingsPlans
    case basicPayTables
    case bahTables
    case basTables
    
    static var payDataCases: [Self] = [.paychecks, .withholdingForms, .thriftSavingsPlans]
    static var tableCases: [Self] = [.basicPayTables, .bahTables, .basTables]
    
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
