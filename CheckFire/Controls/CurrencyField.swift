import SwiftUI

struct CurrencyField: View {
    private let title: String
    @Binding private var value: Decimal

    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
    }

    var body: some View {
        LabeledContent {
            TextField(
                title,
                value: $value,
                format: .currency(code: "USD")
            )
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
        } label: {
            Text(title)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    List {
        CurrencyField("Basic Pay", value: $paycheck.basicPay)
    }
}
