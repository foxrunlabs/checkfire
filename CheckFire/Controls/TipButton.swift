import SwiftUI

struct TipButton: View {
    let tip: String
    let systemName: String
    
    @State private var showTip = false
    
    // MARK: - Initializer
    
    init(_ tip: String, systemName: String) {
        self.tip = tip
        self.systemName = systemName
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            showTip.toggle()
        } label: {
            Image(systemName: systemName)
                .foregroundStyle(.tint)
        }
        .buttonStyle(.borderless)
        .tint(.accentColor)
        .popover(isPresented: $showTip) {
            Text(tip)
                .font(.footnote)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding()
                .frame(width: 320, alignment: .leading)
                .presentationCompactAdaptation(.popover)
        }
    }
}


// MARK: - Preview

#Preview {
    List {
        LabeledContent {
            Text("Content")
        } label: {
            HStack {
                Text("Label")
                TipButton("This is a tip.", systemName: "info.circle")
            }
        }
    }
}
