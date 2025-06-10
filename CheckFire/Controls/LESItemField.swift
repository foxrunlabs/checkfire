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
                if case .entitlement(let entitlement) = lesItem.itemType {
                    Menu {
                        Picker("Entitlement Type", selection: $lesItem.itemType) {
                            ForEach(EntitlementType.allCases) { entitlementType in
                                LabeledContent(String(describing: entitlementType)) {
                                    Image(systemName: icon(for: entitlementType))
                                }
                                .tag(LESItemType.entitlement(entitlementType))
                            }
                        }
                        .pickerStyle(.inline)
                    } label: {
                        Image(systemName: icon(for: entitlement))
                    }
                }
                
                TextField("Item Name", text: $lesItem.name)
            }
        }
    }
    
    private func icon(for entitlementType: EntitlementType) -> String {
        switch entitlementType {
        case .specialPay:
            "s.square"
        case .incentivePay:
            "i.square"
        case .bonusPay:
            "b.square"
        case .allowance:
            "a.square"
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var entitlement = LESItem(
        name: "Entitlement",
        amount: 1.00,
        itemType: .entitlement(.allowance)
    )
    @Previewable @State var deduction = LESItem(
        name: "Deduction",
        amount: 2.00,
        itemType: .deduction
    )
    @Previewable @State var allotment = LESItem(
        name: "Allotment",
        amount: 3.00,
        itemType: .allotment
    )
    
    List {
        LESItemField(lesItem: entitlement)
        LESItemField(lesItem: deduction)
        LESItemField(lesItem: allotment)
    }
}
