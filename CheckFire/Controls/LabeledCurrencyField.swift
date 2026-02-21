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
    
    // MARK: - Initializer
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
    }
    
    // MARK: - Body
    var body: some View {
        TextField(title, text: $text)
            .monospacedDigit()
            .focused($isFocused)
            .onAppear { text = value.formatted(.currency(code: "USD")) }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    // when entering edit mode, show a plain editable number
                    text = value.formatted(.number.precision(.fractionLength(2)).grouping(.never))
                } else {
                    // when leaving edit mode, show currency again
                    commit()
                    text = value.formatted(.currency(code: "USD"))
                }
            }
    }
    
    // MARK: - Methods
    private func commit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            value = 0.00
        } else {
            if let number = try? Decimal(trimmed, format: .number) { value = number }
        }
    }
}
