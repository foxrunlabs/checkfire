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

