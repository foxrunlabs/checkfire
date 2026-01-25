import Foundation
import SwiftUI

struct LabeledCurrency: View {
    let title: LocalizedStringKey
    let value: Decimal
    
    // MARK: - Initializer
    init(_ title: LocalizedStringKey, value: Decimal) {
        self.title = title
        self.value = value
    }
    
    //MARK: - Body
    var body: some View {
        LabeledContent(title) {
            Text(value, format: .currency(code: "USD"))
        }
    }
}
