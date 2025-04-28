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
                
                LESItemField($paycheck.lesData.basePay)
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
            
            LESItemSection(
                "Allowances",
                items: $paycheck.lesData.allowances,
                isEditing: $isEditing
            )
            
            LESItemSection(
                "Special Pays",
                items: $paycheck.lesData.specialPays,
                isEditing: $isEditing
            )
            
            LESItemSection(
                "Deductions",
                items: $paycheck.lesData.deductions,
                isEditing: $isEditing
            )
            
            LESItemSection(
                "Allotments",
                items: $paycheck.lesData.allotments,
                isEditing: $isEditing
            )
        }
    }
}

// MARK: - Preview
#Preview {
    LESDataView(paycheck: Paycheck.example)
}
