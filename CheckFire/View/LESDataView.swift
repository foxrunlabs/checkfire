import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var isEditingEntitlements = false
    @State private var isEditingDeductions = false
    @State private var isEditingAllotments = false
    
    var body: some View {
        Form {
            Group {
                Section {
                    PaycheckDatePicker(
                        "Pay Date",
                        selection: $paycheck.lesData.date,
                        in: TaxYears.shared.years.first!...TaxYears.shared.years.last!
                    )
                    
                    LESItemField($paycheck.lesData.basePay)
                }
                
                LESItemSection(
                    "Entitlements",
                    items: $paycheck.lesData.entitlements,
                    isEditing: $isEditingEntitlements
                ) {
                    let newEntitlement = LESItem(
                        name: "New Entitlement",
                        amount: 0.00,
                        itemType: .specialPay
                    )
                    withAnimation { paycheck.lesData.entitlements.append(newEntitlement) }
                }
                
                LESItemSection(
                    "Deductions",
                    items: $paycheck.lesData.deductions,
                    isEditing: $isEditingDeductions
                ) {
                    let newDeduction = LESItem(
                        name: "New Deduction",
                        amount: 0.00,
                        itemType: .deduction
                    )
                    withAnimation { paycheck.lesData.deductions.append(newDeduction) }
                }
                
                LESItemSection(
                    "Allotments",
                    items: $paycheck.lesData.allotments,
                    isEditing: $isEditingAllotments
                ) {
                    let newAllotment = LESItem(
                        name: "New Allotment",
                        amount: 0.00,
                        itemType: .allotment
                    )
                    withAnimation { paycheck.lesData.allotments.append(newAllotment) }
                }
            }
            .checkFireListRowStyle(themeManager: themeManager)
        }
        .checkFireListBackground(themeManager: themeManager)
    }
}

// MARK: - Preview
#Preview {
    LESDataView(paycheck: Paycheck.example)
        .environment(ThemeManager(theme: .system))
}
