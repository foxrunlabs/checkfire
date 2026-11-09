import SwiftUI

struct NavigationButtons: View {
    @Binding var currentView: AddPaycheckView.SubView
    let previous: AddPaycheckView.SubView?
    let next: AddPaycheckView.SubView?
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()
            
            Button("Previous", systemImage: "arrow.backward.circle") {
                withAnimation { currentView = previous ?? currentView }
            }
            .labelStyle(.iconOnly)
            .disabled(previous == nil)
            
            Spacer()
            
            Button("Next", systemImage: "arrow.forward.circle") {
                withAnimation { currentView = next ?? currentView }
            }
            .labelStyle(.iconOnly)
            .disabled(next == nil)
            
            Spacer()
        }
        .font(.system(size: 64))
    }
}
