import SwiftUI

struct TSPStepper: View {
    init<S>(_ title: S, value: Binding<Decimal>, max: Decimal) where S : StringProtocol {
        self.title = title
        self._value = value
        self.max = max
    }
    
    private let title: any StringProtocol
    @Binding private var value: Decimal
    private let max: Decimal
    
    var body: some View {
        Stepper(
            value: $value,
            in: 0.00...max,
            step: 0.01
        ) {
            HStack {
                Text(title)
                Spacer()
                Text(value.formatted(.percent))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tsp = ThriftSavingsPlan.example
    
    Form {
        Section("Traditional") {
            TSPStepper("Basic Pay", value: $tsp.traditionalBasicPay, max: 1 - tsp.rothBasicPay)
        }
    }
}
