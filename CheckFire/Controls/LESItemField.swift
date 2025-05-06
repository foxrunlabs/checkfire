import SwiftUI

struct LESItemField: View {
    @Binding private var lesItem: LESItem
    private let isEditing: Bool
    private let onDelete: () -> Void
    
    var symbol: String {
        switch lesItem.itemType {
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
    
    init(_ lesItem: Binding<LESItem>) {
        self._lesItem = lesItem
        self.isEditing = false
        self.onDelete = {}
    }
    
    init(_ lesItem: Binding<LESItem>, isEditing: Bool, onDelete: @escaping () -> Void) {
        self._lesItem = lesItem
        self.isEditing = isEditing
        self.onDelete = onDelete
    }
    
    var body: some View {
        if isEditing {
            HStack {
                Button(role: .destructive) {
                    withAnimation { onDelete() }
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                
                TextField("Item Name", text: $lesItem.name)
                
                if lesItem.isEntitlement {
                    Picker("Entitlement Type", selection: $lesItem.itemType) {
                        ForEach(LESItemType.entitlements) { entitlement in
                            Text(String(describing: entitlement))
                                .tag(entitlement)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }
        } else {
            LabeledContent {
                TextField(lesItem.name, value: $lesItem.amount, format: .currency(code: "USD"))
                    .multilineTextAlignment(.trailing)
            } label: {
                HStack {
                    if lesItem.isEntitlement {
                        Image(systemName: symbol)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(lesItem.name)
                }
            }
        }
        
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var basePay = LESItem(name: "Base Pay", amount: 2.00, itemType: .basePay)
    @Previewable @State var allowance = LESItem(name: "Allowance", amount: 1.00, itemType: .allowance)
    @Previewable @State var isEditing = false
    
    VStack {
        Button("Edit") {
            withAnimation { isEditing.toggle() }
        }
        
        List {
            LESItemField($basePay)
            LESItemField($allowance, isEditing: isEditing) { print("Delete") }
        }
    }
}
