import Foundation
import SwiftData
import SwiftUI

struct AddPaycheckView: View {
    @Binding var path: NavigationPath
    
    enum SubView {
        case name
        case payPeriod
        case payGrade
        case basicPay
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentView: SubView = .name
    @State private var paycheck = Paycheck()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                switch currentView {
                case .name:
                    NameView(paycheck: paycheck, currentView: $currentView)
                case .payPeriod:
                    PayPeriodView(paycheck: paycheck, currentView: $currentView)
                case .payGrade:
                    PayGradeView(paycheck: paycheck, currentView: $currentView)
                case .basicPay:
                    BasicPayView(paycheck: paycheck, currentView: $currentView)
                }
            }
            .navigationTitle("Add Paycheck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
                
                if currentView == .basicPay {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", systemImage: "checkmark") {
                            addPaycheck()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func addPaycheck() {
        modelContext.insert(paycheck)
        path.append(paycheck)
    }
}


// MARK: - Preview

#Preview {
    @Previewable @State var showSheet = true
    
    Button("Show Sheet") {
        showSheet = true
    }
    .sheet(isPresented: $showSheet) {
        AddPaycheckView(path: .constant(NavigationPath()))
            .environment(PreviewController.paySystem)
            .modelContainer(PreviewController.container)
    }
}
