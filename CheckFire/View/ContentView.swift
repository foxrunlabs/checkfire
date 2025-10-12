import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedNavigation: SidebarNavigation?
    @State private var selectedPayComponent: PayComponent?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedNavigation: $selectedNavigation)
        } content: {
            ContentViewController(
                selectedNavigation: selectedNavigation,
                selectedPayComponent: $selectedPayComponent
            )
        } detail: {
            DetailViewController(selectedPayComponent: $selectedPayComponent)
        }
        .onChange(of: selectedNavigation) {
            selectedPayComponent = nil
        }
    }
    
    private struct ContentViewController: View {
        let selectedNavigation: SidebarNavigation?
        @Binding var selectedPayComponent: PayComponent?
        
        var body: some View {
            if let selectedNavigation {
                switch selectedNavigation {
                case .paychecks:
                    PaychecksListView(selection: $selectedPayComponent)
                case .withholdingForms:
                    WithholdingFormsListView(selection: $selectedPayComponent)
                case .thriftSavingsPlans:
                    TSPListView(selection: $selectedPayComponent)
                }
            } else {
                ContentUnavailableView(
                    "Nothing Selected",
                    systemImage: "sidebar.left",
                    description: Text("Please select a sidebar item.")
                )
            }
        }
    }
    
    private struct DetailViewController: View {
        @Binding var selectedPayComponent: PayComponent?
        
        var body: some View {
            if let selectedPayComponent {
                switch selectedPayComponent {
                case .paycheck(let selectedPaycheck):
                    PaycheckTabView(for: selectedPaycheck, selection: $selectedPayComponent)
                case .withholdingForm(let selectedWithholdingForm):
                    WithholdingFormDetailView(
                        for: selectedWithholdingForm,
                        selection: $selectedPayComponent
                    )
                case .thriftSavingsPlan(let selectedTSP):
                    TSPDetailView(for: selectedTSP, selection: $selectedPayComponent)
                }
            } else {
                ContentUnavailableView(
                    "Nothing Selected",
                    systemImage: "document",
                    description: Text("Please make a selection.")
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(PreviewController.container)
}
