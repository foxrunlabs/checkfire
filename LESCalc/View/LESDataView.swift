import SwiftData
import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
    @State private var isEditing = false
    
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
                .disabled(isEditing)
                
                LESItemView($lesData.basePay)
            } header: {
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation { isEditing.toggle() }
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                            .font(.body.smallCaps())
                    }
                }
            }
            
            LESDataViewSection("Allowances", items: $lesData.allowances, isEditEnabled: $isEditing)
            
            LESDataViewSection("Special Pays", items: $lesData.specialPays, isEditEnabled: $isEditing)
            
            LESDataViewSection("Deductions", items: $lesData.deductions, isEditEnabled: $isEditing)
            
            LESDataViewSection("Allotments", items: $lesData.allotments, isEditEnabled: $isEditing)
        }
    }
}

#Preview {
    @Previewable @State var lesData = Paycheck.example.lesData
    LESDataView(lesData: $lesData)
}
