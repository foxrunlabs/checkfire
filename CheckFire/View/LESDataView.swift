import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    @State private var isEditing = false
    
    var body: some View {
        Form {
            Section {
                PaycheckDatePicker(
                    "Pay Date",
                    selection: $paycheck.lesData.date,
                    in: TaxYears.shared.years.first!...TaxYears.shared.years.last!
                )
                .disabled(isEditing)
                
                LESItemView($paycheck.lesData.basePay)
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
            
            LESItemSectionView(
                "Allowances",
                lesItems: $paycheck.lesData.allowances,
                isEditing: $isEditing
            )
            
            LESItemSectionView(
                "Special Pays",
                lesItems: $paycheck.lesData.specialPays,
                isEditing: $isEditing
            )
            
            LESItemSectionView(
                "Deductions",
                lesItems: $paycheck.lesData.deductions,
                isEditing: $isEditing
            )
            
            LESItemSectionView(
                "Allotments",
                lesItems: $paycheck.lesData.allotments,
                isEditing: $isEditing
            )
        }
    }
}

#Preview {
    LESDataView(paycheck: Paycheck.example)
}
