import SwiftData
import SwiftUI

struct SidebarView: View {
    @Query(sort: \Paycheck.name) private var paychecks: [Paycheck]
    
    var body: some View {
        List {
            ForEach(paychecks) { paycheck in
                NavigationLink(value: paycheck) {
                    VStack(alignment: .leading) {
                        Text(paycheck.name)
                            .bold()
                        
                        Text(paycheck.date, style: .date)
                    }
                }
            }
        }
        .navigationDestination(for: Paycheck.self) {
            PaycheckView(paycheck: $0)
        }
        .navigationTitle("Paychecks")
    }
}

#Preview {
    SidebarView()
        .modelContainer(PreviewController.container)
}
