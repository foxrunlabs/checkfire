import SwiftData
import SwiftUI

struct LESDataViewSection: View {
    let title: String
    @Binding var items: [LESItem]
    @Binding var isEditEnabled: Bool
    
    init(_ title: String, items: Binding<[LESItem]>, isEditEnabled: Binding<Bool>) {
        self.title = title
        self._items = items
        self._isEditEnabled = isEditEnabled
    }
    
    var body: some View {
        Section {
            ForEach($items) { $item in
                LESItemView($item, isEditing: isEditEnabled) {
                    items.removeAll { $0.id == item.id }
                }
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                if isEditEnabled {
                    Button {
                        let newLESItem = LESItem(name: "New Item", amount: 0.00)
                        
                        withAnimation {
                            items.append(newLESItem)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var allotments = Paycheck.example.lesData.allotments
    @Previewable @State var isEditEnabled = false
    LESDataViewSection("Allotments", items: $allotments, isEditEnabled: $isEditEnabled)
}
