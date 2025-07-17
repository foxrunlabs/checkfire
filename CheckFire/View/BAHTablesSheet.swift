import SwiftUI

struct BAHTablesSheet : View {
    init(year: Int? = nil, zipcode: String? = nil, payGrade: PayGrade? = nil) {
        self.year = year ?? BAHTables.shared.years.first!
        self.zipcode = zipcode ?? ""
        self.payGrade = payGrade ?? .e1
    }
    
    @State private var year: Int
    @AppStorage("zipcode") private var zipcode: String = ""
    @State private var payGrade: PayGrade
    
    @Environment(\.dismiss) private var dismiss
    
    private var withoutDependents: String {
        let rate = BAHTables.shared.bah(for: year, in: zipcode, as: payGrade, withDependents: false)
        return rate?.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var withDependents: String {
        let rate = BAHTables.shared.bah(for: year, in: zipcode, as: payGrade, withDependents: true)
        return rate?.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
    private var mha: String {
        guard let mhaDescription = BAHTables.shared.mha(for: year, in: zipcode) else {
            return "No Data"
        }
        
        let mhaSegments = mhaDescription.split(separator: ", ")
        let area = mhaSegments[0].capitalized
        let state = (mhaSegments.count == 2) ? ", \(mhaSegments[1].uppercased())" : ""
        return area + state
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $year) {
                        ForEach(BAHTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    LabeledContent("ZIP Code") {
                        TextField("ZIP Code", text: $zipcode)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    Picker("Pay Grade", selection: $payGrade) {
                        ForEach(PayGrade.allCases) { grade in
                            Text(String(describing: grade))
                                .tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    LabeledContent("MHA") {
                        Text(mha)
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
