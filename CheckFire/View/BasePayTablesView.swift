import SwiftUI

struct BasePayTablesView: View {
    @State private var year: Int
    @State private var payGrade: PayGrade
    
    @Environment(\.dismiss) private var dismiss
    
    init(year: Int? = nil, payGrade: PayGrade? = nil) {
        self.year = year ?? PayTables.shared.years.first!
        self.payGrade = payGrade ?? .e1
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $year) {
                        ForEach(PayTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Pay Grade", selection: $payGrade) {
                        ForEach(PayGrade.allCases) { grade in
                            Text(String(describing: grade))
                                .tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    HStack {
                        Text("Years of Service")
                            .bold()
                        
                        Spacer()
                        
                        Text("Base Pay")
                            .bold()
                    }
                    
                    ForEach(PayTables.shared.yearsOfServiceAvailable(for: year, as: payGrade), id: \.self) { serviceYear in
                        LabeledContent(String(describing: serviceYear)) {
                            if let basePay = PayTables.shared.basePay(for: year, as: payGrade, with: serviceYear) {
                                Text(basePay, format: .currency(code: "USD"))
                                    .textSelection(.enabled)
                            } else {
                                Text("No Data")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Base Pay Tables")
            .toolbar {
                ToolbarItem {
                    Button("Done", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BasePayTablesView()
    }
}
