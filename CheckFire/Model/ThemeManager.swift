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
    var navigationBarColorScheme: ColorScheme? { themeData.navigationBarColorScheme }
    var toolbarBackground: Color { themeData.toolbarBackground }
    var tabViewTint: Color? { themeData.tabViewTint }
    var scrollBackgroundVisibility: Visibility { themeData.scrollBackgroundVisibility }
    var listBackground: Color { themeData.listBackground }
    var listRowBackground: Color? { themeData.listRowBackground }
    var listRowSeparator: Color? { themeData.listRowSeparator }
    var listSelection: Color? { themeData.listSelection }
    
    private struct ThemeData {
        let colorScheme: ColorScheme?
        let tint: Color?
        let systemBackground: Color
        let navigationBarColorScheme: ColorScheme?
        let toolbarBackground: Color
        let tabViewTint: Color?
        let scrollBackgroundVisibility: Visibility
        let listBackground: Color
        let listRowBackground: Color?
        let listRowSeparator: Color?
        let listSelection: Color?
        
        static let systemTheme = ThemeData(
            colorScheme: nil,
            tint: nil,
            systemBackground: Color(uiColor: .systemBackground),
            navigationBarColorScheme: nil,
            toolbarBackground: Color(uiColor: .systemBackground),
            tabViewTint: nil,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: nil
        )
        
        static let usafTheme = ThemeData(
            colorScheme: .light,
            tint: .usafBlue,
            systemBackground: Color(uiColor: .systemBackground),
            navigationBarColorScheme: .dark,
            toolbarBackground: .usafRoyal,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .white : nil,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: nil
        )
        
        static let usaTheme = ThemeData(
            colorScheme: .dark,
            tint: .armyGold,
            systemBackground: .armyGreen,
            navigationBarColorScheme: nil,
            toolbarBackground: .armyBlack,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .armyGold : nil,
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
            navigationBarColorScheme: .dark,
            toolbarBackground: .uscgRed,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .white : nil,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: nil
        )
        
        static let usmcTheme = ThemeData(
            colorScheme: .dark,
            tint: .navyYellow,
            systemBackground: .marineRed,
            navigationBarColorScheme: nil,
            toolbarBackground: .marineBlue,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .navyYellow : nil,
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
            navigationBarColorScheme: nil,
            toolbarBackground: .navyBlack,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .navyYellow : nil,
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
            navigationBarColorScheme: .dark,
            toolbarBackground: .ussfBlue,
            tabViewTint: UIDevice.current.userInterfaceIdiom == .phone ? .white : nil,
            scrollBackgroundVisibility: .automatic,
            listBackground: Color(uiColor: .systemBackground),
            listRowBackground: nil,
            listRowSeparator: nil,
            listSelection: nil
        )
    }
}
