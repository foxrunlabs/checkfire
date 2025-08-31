import SwiftUI

struct BasicPayTablesSheet: View {
    @State var year: Int?
    @State var payGrade: PayGrade?
    @State var yearsOfService: YearsOfService?
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("paytableYear") private var storedYear = Calendar.current.component(.year, from: .now)
    @AppStorage("paytablePayGrade") private var storedPayGrade = PayGrade.e1
    @AppStorage("paytableYearsOfService") private var storedYearsOfService = YearsOfService.lessThanOrEqual2
    
    private var availableYearsOfService: [YearsOfService] {
        BasicPayTables.shared.yearsOfServiceAvailable(for: storedYear, as: storedPayGrade)
    }
    
    private var basicPay: String {
        let pay = BasicPayTables.shared.basicPay(
            for: storedYear,
            as: storedPayGrade,
            with: storedYearsOfService
        )
        return pay?.formatted(.currency(code: "USD")) ?? "No Data"
    }
    
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
                    
                    Picker("Years of Service", selection: $storedYearsOfService) {
                        ForEach(availableYearsOfService) { serviceYears in
                            Text(String(describing: serviceYears))
                                .tag(serviceYears)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    LabeledContent("Basic Pay") {
                        Text(basicPay)
                            .textSelection(.enabled)
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
                
                if let yearsOfService {
                    storedYearsOfService = yearsOfService
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
            .presentationDetents([.medium])
    }
}
