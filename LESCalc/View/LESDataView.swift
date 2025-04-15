import SwiftData
import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
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
            DatePicker("Pay Date",
                       selection: $lesData.date,
                       in: dateRange,
                       displayedComponents: .date
            )
            
            LabeledContent("Base Pay") {
                TextField(
                    "Base Pay",
                    value: $lesData.basePay,
                    format: .currency(code: "USD")
                )
                .multilineTextAlignment(.trailing)
            }
            
            LESDataViewSection("Allowances", items: $lesData.allowances)
            
            LESDataViewSection("Special Pays", items: $lesData.specialPays)
            
            LESDataViewSection("Deductions", items: $lesData.deductions)
            
            LESDataViewSection("Allotments", items: $lesData.allotments)
        }
    }
}

#Preview {
    @Previewable @State var lesData = Paycheck.example.lesData
    LESDataView(lesData: $lesData)
}
