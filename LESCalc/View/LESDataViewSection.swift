import SwiftData
import SwiftUI

struct LESDataViewSection: View {
    let title: String
    @Binding var items: [LESItem]
    
    @State private var isEditEnabled = false
    
    init(_ title: String, items: Binding<[LESItem]>) {
        self.title = title
        self._items = items
    }
    
    var body: some View {
        Section {
            ForEach($items) { $item in
                LabeledContent {
                    TextField(
                        item.name,
                        value: $item.amount,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                } label: {
                   HStack {
                       if isEditEnabled {
                           Button(role: .destructive) {
                               withAnimation {
                                   items.removeAll { $0.id == item.id }
                               }
                           } label: {
                               Image(systemName: "trash")
                           }
                           .buttonStyle(.borderless)
                       }
                       
                       TextField("Item Name", text: $item.name)
                           .disabled(isEditEnabled == false)
                   }
               }
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                if isEditEnabled == false {
                    Button {
                        withAnimation { isEditEnabled.toggle() }
                    } label: {
                        Text("Edit")
                            .font(.body.smallCaps())
                    }
                } else {
                    Button {
                        let newLESItem = LESItem(name: "New Item", amount: 0.00)
                        
                        withAnimation {
                            items.append(newLESItem)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.smallCaps())
                    }
                    
                    Button {
                        withAnimation { isEditEnabled.toggle() }
                    } label: {
                        Text("Done")
                            .font(.body.smallCaps())
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var allotments = Paycheck.example.lesData.allotments
    LESDataViewSection("Allotments", items: $allotments)
}
