import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
    var body: some View {
        Form {
            Picker("Year", selection: $lesData.year) {
                ForEach(TaxYears.shared.years, id: \.self) { year in
                    Text(year.description)
                        .tag(year)
                }
            }
            
            Section("Entitlements, Deductions, and Allotments") {
                TextField("Base Pay", value: $lesData.basePay, format: .currency(code: "USD"))
                
                TextField("Special and Incentive Pays", value: $lesData.specialPays, format: .currency(code: "USD"))
                
                TextField("Allowances", value: $lesData.allowances, format: .currency(code: "USD"))
                
                TextField("Other Deductions", value: $lesData.otherDeductions, format: .currency(code: "USD"))
                
                TextField("Allotments", value: $lesData.allotments, format: .currency(code: "USD"))
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    LESDataView(lesData: .constant(LESData()))
}
