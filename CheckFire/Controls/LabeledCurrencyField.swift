import Foundation
import SwiftUI

struct LabeledCurrencyField: View {
    let title: String
    @Binding var value: Decimal
    let tip: LocalizedStringKey?
    
    @State private var showTip = false
    
    // MARK: - Initializer
    
    init(_ title: String, value: Binding<Decimal>, tip: LocalizedStringKey? = nil) {
        self.title = title
        self._value = value
        self.tip = tip
    }
    
    // MARK: - Body
    
    var body: some View {
        LabeledContent {
            CurrencyField(title, value: $value)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        } label: {
            HStack {
                Text(title)
                
                if let tip {
                    Button {
                        showTip.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.borderless)
                    .tint(.accentColor)
                    .popover(isPresented: $showTip) {
                        Text(tip)
                            .font(.footnote)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(width: 320, alignment: .leading)
                            .presentationCompactAdaptation(.popover)
                    }
                }
            }
        }
    }
}


// MARK: - Currency Field

fileprivate struct CurrencyField: View {
    let title: String
    @Binding var value: Decimal
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    @State private var validationMessage: String?
    
    // MARK: - Initializer
    
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .trailing) {
            TextField(title, text: $text)
                .monospacedDigit()
                .focused($isFocused)
                .onAppear { text = value.formatted(.currency(code: "USD")) }
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        if validationMessage == nil {
                            // when entering edit mode, show a plain editable number
                            text = value.formatted(.number.precision(.fractionLength(2)).grouping(.never))
                        }
                    } else if commit() {
                        // when leaving edit mode, show currency again
                        text = value.formatted(.currency(code: "USD"))
                    }
                }
            
            if let validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
    // MARK: - Methods
    
    @discardableResult
    private func commit() -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Blank means zero
        if trimmed.isEmpty {
            value = 0.00
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
        
        value = number
        validationMessage = nil
        return true
    }
}
