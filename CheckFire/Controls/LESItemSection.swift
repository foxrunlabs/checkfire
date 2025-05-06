import SwiftUI

struct LESItemSection: View {
    private let title: String
    @Binding private var lesItems: [LESItem]
    @Binding private var isEditing: Bool
    let onAddItem: () -> Void
    
    init(
        _ title: String,
        items: Binding<[LESItem]>,
        isEditing: Binding<Bool>,
        onAddItem: @escaping () -> Void
    ) {
        self.title = title
        self._lesItems = items
        self._isEditing = isEditing
        self.onAddItem = onAddItem
    }
    
    var body: some View {
        Section {
            ForEach($lesItems) { $lesItem in
                LESItemField($lesItem, isEditing: isEditing) {
                    lesItems.removeAll { $0.id == lesItem.id }
                }
            }
            
            if isEditing {
                Button("Add New Item") { onAddItem() }
                    .buttonStyle(.borderless)
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                Button {
                    withAnimation { isEditing.toggle() }
                } label: {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.body.smallCaps())
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var items = [
        LESItem(name: "Test Item 1", amount: 1.00, itemType: .specialPay),
        LESItem(name: "Test Item 2", amount: 2.00, itemType: .allowance)]
    @Previewable @State var isEditing = false
    
    List {
        LESItemSection("Test Section", items: $items, isEditing: $isEditing) {
            let newItem = LESItem(name: "New Item", amount: 0.00, itemType: .specialPay)
            withAnimation { items.append(newItem) }
        }
    }
}
