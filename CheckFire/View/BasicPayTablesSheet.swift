import SwiftUI

struct BasicPayTablesSheet: View {
    @State var year: Int?
    @State var payGrade: PayGrade?
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("paytableYear") private var storedYear = Calendar.current.component(.year, from: .now)
    @AppStorage("paytablePayGrade") private var storedPayGrade = PayGrade.e1
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Year", selection: $storedYear) {
                        ForEach(BasicPayTables.shared.years, id: \.self) { year in
                            Text(String(describing: year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Pay Grade", selection: $storedPayGrade) {
                        ForEach(PayGrade.allCases) { grade in
                            Text(String(describing: grade))
                                .tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    ForEach(YearsOfService.allCases) { yearOfService in
                        if let basicPay = BasicPayTables.shared.basicPay(for: storedYear, as: storedPayGrade, with: yearOfService) {
                            LabeledContent(String(describing: yearOfService)) {
                                Text(basicPay, format: .currency(code: "USD"))
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Basic Pay Tables")
            .toolbar {
                ToolbarItem {
                    Button("Done", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear() {
                if let year {
                    storedYear = year
                }
                
                if let payGrade {
                    storedPayGrade = payGrade
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showSheet = true
    
    Button("Show Basic Pay Tables") {
        showSheet.toggle()
    }
    .sheet(isPresented: $showSheet) {
        BasicPayTablesSheet()
    }
}
