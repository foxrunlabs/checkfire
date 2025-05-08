import SwiftUI

struct CheckFireListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(.navyBlack)
    }
}

struct CheckFireListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.armyTan.opacity(0.2))
            .listRowSeparatorTint(.armyTan.opacity(0.5))
    }
}

extension View {
    func checkFireListStyle() -> some View {
        modifier(CheckFireListStyle())
    }
    
    func checkFireListRowStyle() -> some View {
        modifier(CheckFireListRowStyle())
    }
}
