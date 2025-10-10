import SwiftUI

struct LESItemField: View {
    @Bindable var lesItem: LESItem
    
    var body: some View {
        LabeledContent {
            TextField(lesItem.name, value: $lesItem.amount, format: .currency(code: "USD"))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        } label: {
            HStack {
                if lesItem.type.isEntitlement {
                    Menu {
                        Picker("Entitlement Type", selection: $lesItem.type) {
                            ForEach(LESItemType.entitlementCases) { entitlement in
                                LabeledContent(String(describing: entitlement)) {
                                    Image(systemName: icon(for: entitlement))
                                }
                                .tag(entitlement)
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: icon(for: lesItem.type))
                    }
                }
                
                TextField("Item Name", text: $lesItem.name)
            }
        }
    }
    
    private func icon(for entitlement: LESItemType) -> String {
        switch entitlement {
        case .specialPay:
            "s.square"
        case .incentivePay:
            "i.square"
        case .bonusPay:
            "b.square"
        case .allowance:
            "a.square"
        default:
            ""
        }
    }
}

// MARK: - Preview
#Preview {
    List {
        LESItemField(lesItem: LESItem.exampleEntitlement)
        LESItemField(lesItem: LESItem.exampleDeduction)
        LESItemField(lesItem: LESItem.exampleAllotment)
    }
}
