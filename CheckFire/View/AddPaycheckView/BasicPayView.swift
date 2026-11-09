import SwiftUI

struct BasicPayView: View {
    @Bindable var paycheck: Paycheck
    @Binding var currentView: AddPaycheckView.SubView
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 25) {
            TextField("Basic Pay", value: $paycheck.basicPay, format: .currency(code: "USD"))
                .font(.title)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done"){ dismissKeyboard() }
                    }
                }
            
            Text("What is your basic pay?")
                .font(.title)
                .multilineTextAlignment(.center)
        }
        .padding()
        
        Spacer()
        
        Button("Previous", systemImage: "arrow.backward.circle") {
            withAnimation { currentView = .payGrade }
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 64))
    }
}
