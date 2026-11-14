import SwiftUI

struct BasicPayView: View {
    @Bindable var paycheck: Paycheck
    @Binding var currentView: AddPaycheckView.SubView
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    @State private var validationMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 25) {
            VStack {
                TextField("Basic Pay", text: $text)
                    .font(.title)
                    .monospacedDigit()
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .keyboardType(.decimalPad)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done"){ dismissKeyboard() }
                        }
                    }
                    .onAppear {
                        text = paycheck.basicPay.formatted(.currency(code: "USD"))
                    }
                    .onChange(of: isFocused) { _, focused in
                        if focused {
                            if validationMessage == nil {
                                // when entering edit mode, show a plain editable number
                                text = paycheck.basicPay.formatted(.number.precision(.fractionLength(2)).grouping(.never))
                            }
                        } else if commit() {
                            // when leaving edit mode, show currency again
                            text = paycheck.basicPay.formatted(.currency(code: "USD"))
                        }
                    }
                
                if let validationMessage {
                    Text(validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
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
    
    // MARK: - Methods
    
    @discardableResult
    private func commit() -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Blank means zero
        if trimmed.isEmpty {
            paycheck.basicPay = 0.00
            validationMessage = nil
            return true
        }
        
        guard let number = try? Decimal(trimmed, format: .number) else {
            validationMessage = "Enter a valid amount."
            return false
        }
        
        guard number >= 0 else {
            validationMessage = "Enter an amount of $0.00 or more."
            return false
        }
        
        paycheck.basicPay = number
        validationMessage = nil
        return true
    }
}
