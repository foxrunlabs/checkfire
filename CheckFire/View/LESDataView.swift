import SwiftUI

struct LESDataView: View {
    @Bindable var paycheck: Paycheck
    
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var isEditingEntitlements = false
    @State private var isEditingDeductions = false
    @State private var isEditingAllotments = false
    
    private var yearsOfService: [YearsOfService] {
        PayTables.shared.yearsOfServiceAvailable(
            for: paycheck.lesData.date.year,
            as: paycheck.lesData.payGrade
        )
    }
    
    var body: some View {
        Form {
            Group {
                Section {
                    PaycheckDatePicker(
                        "Pay Date",
                        selection: $paycheck.lesData.date,
                        in: WithholdingTables.shared.years.first!...WithholdingTables.shared.years.last!
                    )
                    
                    Picker("Pay Grade", selection: $paycheck.lesData.payGrade) {
                        ForEach(PayGrade.allCases) { grade in
                            Text(String(describing: grade))
                                .tag(grade)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if yearsOfService.isEmpty {
                        LabeledContent("Years of Service") {
                            Text("No Data")
                        }
                    } else {
                        Picker("Years of Service", selection: $paycheck.lesData.yearsOfService) {
                            ForEach(yearsOfService) { serviceYears in
                                Text(String(describing: serviceYears))
                                    .tag(serviceYears)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
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
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: paycheck.lesData.payGrade) {
            updateBasePay(
                for: paycheck.lesData.payGrade,
                yearsOfService: paycheck.lesData.yearsOfService
            )
        }
        .onChange(of: paycheck.lesData.yearsOfService) {
            updateBasePay(
                for: paycheck.lesData.payGrade,
                yearsOfService: paycheck.lesData.yearsOfService
            )
        }
    }
    
    private func updateBasePay(for grade: PayGrade, yearsOfService: YearsOfService) {
        paycheck.lesData.basePay.amount = PayTables.shared.basePay(
            for: paycheck.lesData.date.year,
            as: paycheck.lesData.payGrade,
            with: paycheck.lesData.yearsOfService
        ) ?? 0.00
    }
}

// MARK: - Preview
#Preview {
    LESDataView(paycheck: Paycheck.example)
        .environment(ThemeManager(theme: .system))
}
