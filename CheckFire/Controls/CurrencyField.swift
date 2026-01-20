import SwiftUI

struct CurrencyField: View {
    let title: String
    @Binding var value: Decimal
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Initializer
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
    }
    
    // MARK: - Computed Properties
    private let plainFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .none
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.generatesDecimalNumbers = true
        return f
    }()
    
    // MARK: - Body
    var body: some View {
        TextField(title, text: $text)
            .focused($isFocused)
            .onAppear { text = value.formatted(.currency(code: "USD")) }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    // when entering edit mode, show a plain editable number
                    text = plainFormatter.string(from: value as NSDecimalNumber) ?? ""
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
            if let number = try? Decimal(trimmed, format: .number) {
                value = number
            }
        }
    }
}
