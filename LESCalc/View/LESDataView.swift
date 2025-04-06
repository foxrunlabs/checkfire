import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Year", selection: $lesData.year) {
                    ForEach(TaxYears.shared.years, id: \.self) { year in
                        Text(year.description)
                            .tag(year)
                    }
                }
                
                Section("Entitlements, Deductions, and Allotments") {
                    LabeledContent {
                        TextField(
                            "Base Pay",
                            value: $lesData.basePay,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Base Pay")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Special and Incentive Pays",
                            value: $lesData.specialPays,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Special and Incentive Pays")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Allowances",
                            value: $lesData.allowances,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Allowances")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Other Deductions",
                            value: $lesData.otherDeductions,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Other Deductions")
                    }
                    
                    LabeledContent {
                        TextField(
                            "Allotments",
                            value: $lesData.allotments,
                            format: .currency(code: "USD")
                        )
                        .multilineTextAlignment(.trailing)
                    } label: {
                        Text("Allotments")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Pay Period")
            .navigationBarTitleDisplayMode(UIDevice.isiPad ? .large : .inline)
        }
    }
}

#Preview {
    @Previewable @State var lesData = LESData()
    LESDataView(lesData: $lesData)
}
