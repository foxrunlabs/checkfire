import SwiftData
import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
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
                selection: $paycheck.date,
                in: dateRange,
                displayedComponents: .date
            )
            
            LabeledContent("Base Pay") {
                TextField(
                    "Base Pay",
                    value: $paycheck.lesData.basePay,
                    format: .currency(code: "USD")
                )
                .multilineTextAlignment(.trailing)
            }
            
            LESDataViewSection("Allowances", items: $paycheck.lesData.allowances)
            
            LESDataViewSection("Special Pays", items: $paycheck.lesData.specialPays)
            
            LESDataViewSection("Deductions", items: $paycheck.lesData.deductions)
            
            LESDataViewSection("Allotments", items: $paycheck.lesData.allotments)
        }
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    LESDataView(paycheck: paycheck)
}
