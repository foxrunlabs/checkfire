import SwiftData
import SwiftUI

struct PaycheckTabView: View {
    @Bindable private var paycheck: Paycheck
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showBasicPayTablesSheet = false
    @State private var showBAHTablesSheet = false
    @State private var showBASTablesSheet = false
    
    init(for paycheck: Paycheck) {
        self.paycheck = paycheck
    }
    
    private var paycheckYear: Int { Calendar.current.component(.year, from: paycheck.date) }
    
    var body: some View {
        TabView {
            Tab("Paycheck", systemImage: "dollarsign") {
                PaycheckDetailView(for: paycheck)
            }
            
            Tab("Net Pay", systemImage: "plus.forwardslash.minus") {
                NetPayView(for: paycheck)
            }
        }
        .navigationTitle($paycheck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Basic Pay Tables", systemImage: "tablecells") {
                        showBasicPayTablesSheet.toggle()
                    }
                    
                    Button("BAH Tables", systemImage: "house") {
                        showBAHTablesSheet.toggle()
                    }
                    
                    Button("BAS Tables", systemImage: "fork.knife") {
                        showBASTablesSheet.toggle()
                    }
                    
                    Button("Delete Paycheck", systemImage: "trash", role: .destructive) {
                        deletePaycheck()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showBasicPayTablesSheet) {
            BasicPayTablesSheet(year: paycheckYear, payGrade: paycheck.payGrade)
        }
        .sheet(isPresented: $showBAHTablesSheet) {
            BAHTablesSheet(year: paycheckYear, payGrade: paycheck.payGrade)
        }
        .sheet(isPresented: $showBASTablesSheet) {
            BASTablesSheet(year: paycheckYear)
        }
    }
    
    private func deletePaycheck() {
        modelContext.delete(paycheck)
    }
}

#Preview {
    @Previewable @State var paycheck = Paycheck.example
    
    NavigationStack {
        PaycheckTabView(for: paycheck)
    }
    .modelContainer(PreviewController.container)
}
