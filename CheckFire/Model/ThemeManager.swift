import Observation
import SwiftUI

@Observable
final class ThemeManager {
    var theme: Theme {
        willSet {
            themeData = switch theme {
            case .system:
                ThemeData.systemTheme
            case .usaf:
                ThemeData.usafTheme
            case .usa:
                ThemeData.usaTheme
            case .uscg:
                ThemeData.uscgTheme
            case .usmc:
                ThemeData.usmcTheme
            case .usn:
                ThemeData.usnTheme
            case .ussf:
                ThemeData.ussfTheme
            }
        }
    }
    
    init(theme: Theme = .system) {
        self.theme = theme
        self.themeData = switch theme {
        case .system:
            ThemeData.systemTheme
        case .usaf:
            ThemeData.usafTheme
        case .usa:
            ThemeData.usaTheme
        case .uscg:
            ThemeData.uscgTheme
        case .usmc:
            ThemeData.usmcTheme
        case .usn:
            ThemeData.usnTheme
        case .ussf:
            ThemeData.ussfTheme
        }
    }
    
    private var themeData: ThemeData
    
    var colorScheme: ColorScheme? { themeData.colorScheme }
    var tint: Color? { themeData.tint }
    var systemBackground: Color { themeData.systemBackground }
    var tabViewBackground: Color { themeData.tabViewBackground }
    var tabViewTint: Color? { themeData.tabViewTint }
    var scrollBackgroundVisibility: Visibility { themeData.scrollBackgroundVisibility }
    var listBackground: Color { themeData.listBackground }
    var listRowBackground: Color? { themeData.listRowBackground }
    var listRowSeparator: Color? { themeData.listRowSeparator }
    var listSelection: Color { themeData.listSelection }
    
    private struct ThemeData {
        let colorScheme: ColorScheme?
        let tint: Color?
        let systemBackground: Color
        let tabViewBackground: Color
        let tabViewTint: Color?
        let scrollBackgroundVisibility: Visibility
        let listBackground: Color
        let listRowBackground: Color?
        let listRowSeparator: Color?
        let listSelection: Color
        
        static let systemTheme = ThemeData(
            colorScheme: nil,
            tint: nil,
            systemBackground: Color(uiColor: .systemBackground),
            tabViewBackground: Color(uiColor: .systemBackground),
            tabViewTint: nil,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: Color(uiColor: .systemFill)
        )
        
        static let usafTheme = ThemeData(
            colorScheme: .light,
            tint: .usafBlue,
            systemBackground: Color(uiColor: .systemBackground),
            tabViewBackground: .usafRoyal,
            tabViewTint: .white,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: Color(uiColor: .systemFill)
        )
        
        static let usaTheme = ThemeData(
            colorScheme: .dark,
            tint: .armyGold,
            systemBackground: .armyGreen,
            tabViewBackground: .armyBlack,
            tabViewTint: .armyGold,
            scrollBackgroundVisibility: .hidden,
            listBackground: .armyGreen,
            listRowBackground: .armyTan.opacity(0.2),
            listRowSeparator: .armyTan.opacity(0.5),
            listSelection: .armyTan.opacity(0.2)
        )
        
        static let uscgTheme = ThemeData(
            colorScheme: .light,
            tint: .uscgBlue,
            systemBackground: Color(uiColor: .systemBackground),
            tabViewBackground: .uscgRed,
            tabViewTint: .white,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: Color(uiColor: .systemFill)
        )
        
        static let usmcTheme = ThemeData(
            colorScheme: .dark,
            tint: .navyYellow,
            systemBackground: .marineRed,
            tabViewBackground: .marineBlue,
            tabViewTint: .navyYellow,
            scrollBackgroundVisibility: .hidden,
            listBackground: .marineRed,
            listRowBackground: .armyTan.opacity(0.2),
            listRowSeparator: .armyTan.opacity(0.5),
            listSelection: .armyTan.opacity(0.2)
        )
        
        static let usnTheme = ThemeData(
            colorScheme: .dark,
            tint: .navyYellow,
            systemBackground: .navyBlue,
            tabViewBackground: .navyBlack,
            tabViewTint: .navyYellow,
            scrollBackgroundVisibility: .hidden,
            listBackground: .navyBlue,
            listRowBackground: .armyTan.opacity(0.2),
            listRowSeparator: .armyTan.opacity(0.5),
            listSelection: .armyTan.opacity(0.2)
        )
        
        static let ussfTheme = ThemeData(
            colorScheme: .light,
            tint: .usafBlue,
            systemBackground: Color(uiColor: .systemBackground),
            tabViewBackground: .ussfBlue,
            tabViewTint: .white,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: Color(uiColor: .systemFill)
        )
    }
}
