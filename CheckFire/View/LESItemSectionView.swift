import SwiftUI

struct LESItemSectionView: View {
    let title: String
    @Binding var lesItems: [LESItem]
    @Binding var isEditing: Bool
    
    init(_ title: String, lesItems: Binding<[LESItem]>, isEditing: Binding<Bool>) {
        self.title = title
        self._lesItems = lesItems
        self._isEditing = isEditing
    }
    
    var body: some View {
        Section {
            ForEach($lesItems) { $lesItem in
                LESItemView($lesItem, isEditing: isEditing) {
                    lesItems.removeAll { $0.id == lesItem.id }
                }
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                if isEditing {
                    Button {
                        let newLESItem = LESItem(name: "New Item", amount: 0.00)
                        withAnimation { lesItems.append(newLESItem) }
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
}
