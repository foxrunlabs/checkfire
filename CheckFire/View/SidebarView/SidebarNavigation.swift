import SwiftUI

enum SidebarNavigation: CaseIterable, CustomStringConvertible, Identifiable {
    case paychecks
        
    // MARK: - Computed Properties
    var icon: String {
        switch self {
        case .paychecks:
            "dollarsign"
        }
    }
    
    var color: Color {
        switch self {
        case .paychecks:
            .green
        }
    }
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .paychecks: "Paychecks"
        }
    }
    
    // MARK: - Identifiable
    var id: Self { self }
}
