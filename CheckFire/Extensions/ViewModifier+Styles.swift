import SwiftUI

struct CheckFireNavigationBarStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(themeManager.toolbarBackground, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarColorScheme(themeManager.navigationBarColorScheme, for: .navigationBar)
    }
}

struct CheckFireTabStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(themeManager.toolbarBackground, for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
            .tint(themeManager.tint)
    }
}

struct CheckFireListBackgroundStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        if themeManager.theme != .system {
            content
                .scrollContentBackground(themeManager.scrollBackgroundVisibility)
                .background(themeManager.listBackground)
        } else {
            content
        }
        
    }
}

struct CheckFireListRowStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .listRowBackground(themeManager.listRowBackground)
            .listRowSeparatorTint(themeManager.listRowSeparator)
    }
}

extension View {
    func checkFireNavigationBarStyle(themeManager: ThemeManager) -> some View {
        modifier(CheckFireNavigationBarStyle(themeManager: themeManager))
    }
    
    func checkFireTabStyle(themeManager: ThemeManager) -> some View {
        modifier(CheckFireTabStyle(themeManager: themeManager))
    }
    
    func checkFireListBackground(themeManager: ThemeManager) -> some View {
        modifier(CheckFireListBackgroundStyle(themeManager: themeManager))
    }
    
    func checkFireListRowStyle(themeManager: ThemeManager) -> some View {
        modifier(CheckFireListRowStyle(themeManager: themeManager))
    }
}
