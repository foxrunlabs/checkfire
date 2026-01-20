import Foundation
import SwiftUI

struct LabeledCurrencyField: View {
    let title: String
    @Binding var value: Decimal
    
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
    }
    
    var body: some View {
        LabeledContent(title) {
            CurrencyField(title, value: $value)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        }
    }
}

