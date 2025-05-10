import SwiftUI

struct CheckFireTabViewStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(themeManager.tabViewBackground, for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
    }
}

struct CheckFireListBackgroundStyle: ViewModifier {
    let themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(themeManager.scrollBackgroundVisibility)
            .background(themeManager.listBackground)
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
    func checkFireTabViewStyle(themeManager: ThemeManager) -> some View {
        modifier(CheckFireTabViewStyle(themeManager: themeManager))
    }
    
    func checkFireListBackground(themeManager: ThemeManager) -> some View {
        modifier(CheckFireListBackgroundStyle(themeManager: themeManager))
    }
    
    func checkFireListRowStyle(themeManager: ThemeManager) -> some View {
        modifier(CheckFireListRowStyle(themeManager: themeManager))
    }
}
