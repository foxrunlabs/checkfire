import SwiftUI

struct PayPeriodView: View {
    @Bindable var paycheck: Paycheck
    @Binding var currentView: AddPaycheckView.SubView
    
    @Environment(PaySystem.self) private var paySystem
    
    // MARK: - Computed Properties
    
    private var taxYears: [Int] { Array(paySystem.taxYears) }
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 25) {
            HStack {
                Picker("Month", selection: $paycheck.payPeriod.month) {
                    ForEach(Month.allCases) { month in
                        Text(month.shortSymbol)
                            .font(.title)
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("Year", selection: $paycheck.payPeriod.year) {
                    ForEach(taxYears, id: \.self) { year in
                        Text(year, format: .number.grouping(.never))
                            .font(.title)
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
            }
            
            Text("What pay period does this paycheck cover?")
                .multilineTextAlignment(.center)
        }
        .font(.title)
        .padding()
        
        Spacer()
        
        NavigationButtons(currentView: $currentView, previous: .name, next: .payGrade)
    }
}
