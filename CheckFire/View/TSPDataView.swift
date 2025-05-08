import SwiftUI

struct TSPDataView: View {
    @Bindable var paycheck: Paycheck
    
    var body: some View {
        Form {
            Group {
                Section("Traditional TSP") {
                    TSPStepper("Base Pay", value: $paycheck.tspData.traditionalBasePay)
                    
                    TSPStepper("Special Pay", value: $paycheck.tspData.traditionalSpecialPay)
                        .disabled(paycheck.tspData.traditionalBasePay == 0)
                    
                    TSPStepper("Incentive Pay", value: $paycheck.tspData.traditionalIncentivePay)
                        .disabled(paycheck.tspData.traditionalBasePay == 0)
                    
                    TSPStepper("Bonus Pay", value: $paycheck.tspData.traditionalBonusPay)
                        .disabled(paycheck.tspData.traditionalBasePay == 0)
                }
                
                Section("Roth TSP") {
                    TSPStepper("Base Pay", value: $paycheck.tspData.rothBasePay)
                    
                    TSPStepper("Special Pay", value: $paycheck.tspData.rothSpecialPay)
                        .disabled(paycheck.tspData.rothBasePay == 0)
                    
                    TSPStepper("Incentive Pay", value: $paycheck.tspData.rothIncentivePay)
                        .disabled(paycheck.tspData.rothBasePay == 0)
                    
                    TSPStepper("Bonus Pay", value: $paycheck.tspData.rothBonusPay)
                        .disabled(paycheck.tspData.rothBasePay == 0)
                }
            }
            .checkFireListRowStyle()
        }
        .checkFireListStyle()
    }
}

// MARK: - Preview
#Preview {
    TSPDataView(paycheck: Paycheck.example)
}
