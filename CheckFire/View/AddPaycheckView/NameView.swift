import SwiftUI

struct NameView: View {
    @Bindable var paycheck: Paycheck
    @Binding var currentView: AddPaycheckView.SubView
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 25) {
            TextField("Paycheck Name", text: $paycheck.name)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
            
            Text("What do you want to name your paycheck?")
                .multilineTextAlignment(.center)
        }
        .font(.title)
        .padding()
        
        Spacer()
        
        Button("Next", systemImage: "arrow.forward.circle") {
            withAnimation { currentView = .payPeriod }
        }
        .font(.system(size: 64))
        .labelStyle(.iconOnly)
    }
}
