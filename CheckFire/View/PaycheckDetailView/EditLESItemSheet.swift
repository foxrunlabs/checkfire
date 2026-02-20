import SwiftUI

struct EditLESItemSheet: View {
    @Binding var lesItem: Paycheck.LESItem
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Properties
    private var categories: [Paycheck.LESItem.Category] {
        lesItem.isEntitlement ? Paycheck.LESItem.Category.entitlementCases : [.deduction, .allotment]
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $lesItem.name)
                        .multilineTextAlignment(.trailing)
                }
                
                LabeledCurrencyField("Amount", value: $lesItem.amount)
                Picker("Type", selection: $lesItem.category) {
                    ForEach(categories) { category in
                        Text(String(describing: category))
                            .tag(category)
                    }
                }
            }
            .navigationTitle("Edit LES Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                        .buttonStyle(.glassProminent)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { dismissKeyboard() }
                }
            }
        }
    }
    
    // MARK: - Methods
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var showSheet = true
    @Previewable @State var lesItem = Paycheck.example.lesItems[0]
    
    Button("Show Sheet") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        EditLESItemSheet(lesItem: $lesItem)
            .presentationDetents([.medium])
    }
}
