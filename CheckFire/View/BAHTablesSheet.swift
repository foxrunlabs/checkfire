import SwiftUI

struct BAHTablesSheet : View {
    @State var year: Int?
    @State var zipcode: String?
    @State var payGrade: PayGrade?
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bahYear") private var storedYear = Calendar.current.component(.year, from: .now)
    @AppStorage("bahZIPCode") private var storedZIPCode = "60088"
    @AppStorage("bahPayGrade") private var storedPayGrade = PayGrade.e1
    
    private var withoutDependents: String {
        let rate = BAHTables.shared.bah(
            for: storedYear,
            in: storedZIPCode,
            as: storedPayGrade,
            withDependents: false
        )
        return rate?.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var withDependents: String {
        let rate = BAHTables.shared.bah(
            for: storedYear,
            in: storedZIPCode,
            as: storedPayGrade,
            withDependents: true
        )
        return rate?.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var mha: String {
        BAHTables.shared.mhaName(for: storedYear, in: storedZIPCode) ?? "No Data"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $storedYear) {
                        ForEach(BAHTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    LabeledContent("ZIP Code") {
                        TextField("ZIP Code", text: $storedZIPCode)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    Picker("Pay Grade", selection: $storedPayGrade) {
                        ForEach(PayGrade.allCases) { grade in
                            Text(String(describing: grade))
                                .tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    HStack {
                        Text("Military Housing Area")
                            .fixedSize()
                        
                        Spacer()
                        
                        Text(mha)
                            .foregroundStyle(.secondary)
                    }
                    
                    LabeledContent("Without Dependents") {
                        Text(withoutDependents)
                            .textSelection(.enabled)
                    }
                    
                    LabeledContent("With Dependents") {
                        Text(withDependents)
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("BAH Tables")
            .toolbar {
                ToolbarItem {
                    Button("Done", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
            .onAppear {
                if let year {
                    storedYear = year
                }
                
                if let zipcode {
                    storedZIPCode = zipcode
                }
                
                if let payGrade {
                    storedPayGrade = payGrade
                }
            }
        }
    }
    
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
    
    Button("Show BAH Tables") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        BAHTablesSheet()
    }
}
