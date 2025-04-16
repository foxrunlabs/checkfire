import SwiftData
import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
    @State private var isEditEnabled = false
    
    private var dateRange: ClosedRange<Date> {
        let startDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.first!,
            month: 1, day: 1
        ).date!
        
        let lastDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.last!,
            month: 12,
            day: 31
        ).date!
        
        return startDate...lastDate
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker("Pay Date",
                           selection: $lesData.date,
                           in: dateRange,
                           displayedComponents: .date
                )
                .disabled(isEditEnabled)
                
                LabeledContent("Base Pay") {
                    TextField(
                        "Base Pay",
                        value: $lesData.basePay,
                        format: .currency(code: "USD")
                    )
                    .multilineTextAlignment(.trailing)
                    .disabled(isEditEnabled)
                }
            } header: {
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation { isEditEnabled.toggle() }
                    } label: {
                        Text(isEditEnabled ? "Done" : "Edit")
                            .font(.body.smallCaps())
                    }
                }
            }
            
            LESDataViewSection("Allowances", items: $lesData.allowances, isEditEnabled: $isEditEnabled)
            
            LESDataViewSection("Special Pays", items: $lesData.specialPays, isEditEnabled: $isEditEnabled)
            
            LESDataViewSection("Deductions", items: $lesData.deductions, isEditEnabled: $isEditEnabled)
            
            LESDataViewSection("Allotments", items: $lesData.allotments, isEditEnabled: $isEditEnabled)
        }
    }
}

#Preview {
    @Previewable @State var lesData = Paycheck.example.lesData
    LESDataView(lesData: $lesData)
}
