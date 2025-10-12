import SwiftUI

struct SomeView: View {
    @State private var date = Date.now
    @State private var show = false
    
    var body: some View {
        Button("Click Me") {
            show.toggle()
        }
        .popover(isPresented: $show) {
            PopView(date: $date)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    struct PopView: View {
        @Binding var date: Date
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            HStack {
                MonthYearPicker(selection: $date, in: WithholdingTables.shared.years)
                Spacer()
                Button("Add", systemImage: "checkmark") { dismiss() }.labelStyle(.iconOnly)
            }
            .padding()
        }
    }
}

#Preview {
    SomeView()
}
