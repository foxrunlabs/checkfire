import SwiftUI

struct CurrencyField: View {
    init<S>(_ title: S, value: Binding<Decimal>) where S : StringProtocol {
        self.title = title
        self._value = value
    }
    
    private let title: any StringProtocol
    @Binding private var value: Decimal

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
