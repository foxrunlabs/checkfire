import SwiftUI

struct LESDataView: View {
    @Binding var lesData: LESData
    
    @State private var isEditing = false
    
    private var dateRange: ClosedRange<Date> {
        let startDate = DateComponents(
            calendar: .current,
            year: TaxYears.shared.years.first!,
            month: 1,
            day: 1
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
                PaycheckDatePicker(
                    "Pay Date",
                    selection: $lesData.date,
                    in: TaxYears.shared.years.first!...TaxYears.shared.years.last!
                )
                .disabled(isEditing)
                
                LESItemView($lesData.basePay)
                    .disabled(isEditing)
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
            
            LESItemSectionView("Allowances", lesItems: $lesData.allowances, isEditing: $isEditing)
            
            LESItemSectionView("Special Pays", lesItems: $lesData.specialPays, isEditing: $isEditing)
            
            LESItemSectionView("Deductions", lesItems: $lesData.deductions, isEditing: $isEditing)
            
            LESItemSectionView("Allotments", lesItems: $lesData.allotments, isEditing: $isEditing)
        }
    }
}

#Preview {
    @Previewable @State var lesData = Paycheck.example.lesData
    LESDataView(lesData: $lesData)
}
