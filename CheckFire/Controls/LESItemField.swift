import SwiftUI

struct LESItemField: View {
    @Binding private var lesItem: LESItem
    private let isEditing: Bool
    private let onDelete: () -> Void
    
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
        LabeledContent {
            TextField(lesItem.name, value: $lesItem.amount, format: .currency(code: "USD"))
                .multilineTextAlignment(.trailing)
                .disabled(isEditing)
                .opacity(isEditing ? 0 : 1)
        } label: {
           HStack {
               if isEditing {
                   Button(role: .destructive) {
                       withAnimation { onDelete() }
                   } label: {
                       Image(systemName: "trash")
                   }
                   .buttonStyle(.borderless)
               }
               
               TextField("Item Name", text: $lesItem.name)
                   .disabled(isEditing == false)
           }
       }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var item = LESItem(name: "Test Item", amount: 0.00)
    @Previewable @State var isEditing = false
    
    VStack {
        Button("Edit") {
            withAnimation { isEditing.toggle() }
        }
        
        List {
            LESItemField($item)
            LESItemField($item, isEditing: isEditing) { print("Delete") }
        }
    }
}
