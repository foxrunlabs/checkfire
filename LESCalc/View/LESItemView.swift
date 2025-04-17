import SwiftUI

struct LESItemView: View {
    @Binding var item: LESItem
    let isEditing: Bool
    let onDelete: () -> Void
    
    init(_ item: Binding<LESItem>) {
        self._item = item
        self.isEditing = false
        self.onDelete = {}
    }
    
    init(_ item: Binding<LESItem>, isEditing: Bool, onDelete: @escaping () -> Void) {
        self._item = item
        self.isEditing = isEditing
        self.onDelete = onDelete
    }
    
    var body: some View {
        LabeledContent {
            TextField(
                item.name,
                value: $item.amount,
                format: .currency(code: "USD")
            )
            .multilineTextAlignment(.trailing)
            .disabled(isEditing)
        } label: {
           HStack {
               if isEditing {
                   Button(role: .destructive) {
                       withAnimation {
                           onDelete()
                       }
                   } label: {
                       Image(systemName: "trash")
                   }
                   .buttonStyle(.borderless)
               }
               
               TextField("Item Name", text: $item.name)
                   .disabled(isEditing == false)
           }
       }
    }
}
