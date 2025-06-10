enum SidebarNavigation: CaseIterable, CustomStringConvertible, Identifiable {
    case paychecks
    case withholdingForms
    case thriftSavingsPlans
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .paychecks: "Paychecks"
        case .withholdingForms: "Withholding Forms"
        case .thriftSavingsPlans: "Thrift Savings Plans"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
