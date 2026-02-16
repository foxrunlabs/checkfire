import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedNavigation: SidebarNavigation?
    @State private var selectedDetail: DetailSelection?
    
    // MARK: - Body
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedNavigation: $selectedNavigation)
        } content: {
            ContentViewController(
                selectedNavigation: selectedNavigation,
                selectedDetail: $selectedDetail
            )
        } detail: {
            DetailViewController(selectedDetail: $selectedDetail)
        }
        .onChange(of: selectedNavigation) {
            selectedDetail = nil
        }
    }
}


// MARK: - Content View Controller
fileprivate struct ContentViewController: View {
    let selectedNavigation: SidebarNavigation?
    @Binding var selectedDetail: DetailSelection?
    
    // MARK: - Body
    var body: some View {
        if let selectedNavigation {
            switch selectedNavigation {
            case .paychecks:
                PaychecksListView(selection: $selectedDetail)
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


// MARK: - Detail View Controller
fileprivate struct DetailViewController: View {
    @Binding var selectedDetail: DetailSelection?
    
    // MARK: - Body
    var body: some View {
        if let selectedDetail {
            switch selectedDetail {
            case .paycheck(let selectedPaycheck):
                PaycheckDetailView(paycheck: selectedPaycheck, selection: $selectedDetail)
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


// MARK: - Preview
#Preview {
    ContentView()
        .environment(WithholdingTableRepository(from: "withholding_tables.json"))
        .modelContainer(PreviewController.container)
}
