import SwiftData
import SwiftUI

struct SidebarView: View {
    @Query(sort: \Paycheck.name) private var paychecks: [Paycheck]
    
    var body: some View {
        List {
            Section("Paychecks") {
                ForEach(paychecks) { paycheck in
                    NavigationLink(value: paycheck) {
                        Text(paycheck.name)
                    }
                }
            }
        }
        .navigationDestination(for: Paycheck.self) {
            PaycheckView(paycheck: $0)
        }
        .navigationTitle("LES Calc")
        .navigationBarTitleDisplayMode(.inline)
    }
}
