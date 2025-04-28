import SwiftUI

struct LESItemSection: View {
    private let title: String
    @Binding private var lesItems: [LESItem]
    @Binding private var isEditing: Bool
    
    init(_ title: String, items: Binding<[LESItem]>, isEditing: Binding<Bool>) {
        self.title = title
        self._lesItems = items
        self._isEditing = isEditing
    }
    
    var body: some View {
        Section {
            ForEach($lesItems) { $lesItem in
                LESItemField($lesItem, isEditing: isEditing) {
                    lesItems.removeAll { $0.id == lesItem.id }
                }
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                if isEditing {
                    Button {
                        addLESItem()
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
    
    private func addLESItem() {
        let newLESItem = LESItem(name: "New Item", amount: 0.00)
        withAnimation { lesItems.append(newLESItem) }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var items: [LESItem] = [
        LESItem(name: "Test Item 1", amount: 1.00),
        LESItem(name: "Test Item 2", amount: 2.00)
    ]
    @Previewable @State var isEditing = false
    
    VStack {
        Button("Edit") {
            withAnimation { isEditing.toggle() }
        }
        
        List {
            LESItemSection("Test Section", items: $items, isEditing: $isEditing)
        }
    }
}
