import SwiftUI

struct PayGradeView: View {
    @Bindable var paycheck: Paycheck
    @Binding var currentView: AddPaycheckView.SubView
    
    // MARK: - Body
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 25) {
            HStack {
                Picker("Pay Grade", selection: $paycheck.payGrade) {
                    ForEach(Paycheck.PayGrade.allCases) { grade in
                        Text(grade.displayName)
                            .font(.title)
                            .tag(grade)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("Years of Service", selection: $paycheck.yearsOfService) {
                    ForEach(Paycheck.YearsOfService.allCases) { serviceYears in
                        Text(serviceYears.displayName)
                            .font(.title)
                            .tag(serviceYears)
                    }
                }
                .pickerStyle(.wheel)
            }
            
            Text("What is your pay grade?")
                .multilineTextAlignment(.center)
        }
        .font(.title)
        .padding()
        
        Spacer()
        
        NavigationButtons(currentView: $currentView, previous: .payPeriod, next: .basicPay)
    }
}
