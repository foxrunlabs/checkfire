import Foundation
import SwiftUI

struct TSPStepper: View {
    let title: LocalizedStringKey
    @Binding var value: Decimal
    let max: Decimal
    
    // MARK: - Initializer
    init(_ title: LocalizedStringKey, value: Binding<Decimal>, max: Decimal) {
        self.title = title
        self._value = value
        self.max = max
    }
    
    // MARK: - Body
    var body: some View {
        Stepper(value: $value, in: 0.00...max, step: 0.01) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .percent)
            }
        }
    }
}
