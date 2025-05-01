import SwiftUI

struct TSPStepper: View {
    let title: String
    @Binding var value: Double
    
    init(_ title: String, value: Binding<Double>) {
        self.title = title
        self._value = value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(value.formatted(.percent))
            }
            
            Slider(value: $value, in: 0...1, step: 0.01)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tspData = TSPData.example
    
    Form {
        TSPStepper("Base Pay", value: $tspData.traditionalBasePay)
    }
}
