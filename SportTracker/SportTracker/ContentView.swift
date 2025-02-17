import SwiftUI

struct ContentView: View {
    @StateObject private var addPerformanceViewModel: AddPerformanceViewModel
    @StateObject private var performanceListViewModel: PerformanceListViewModel
    @StateObject private var tabSelectionViewModel = TabSelectionViewModel()

    init(
        addPerformanceViewModel: AddPerformanceViewModel,
        performanceListViewModel: PerformanceListViewModel
    ) {
        _addPerformanceViewModel = StateObject(wrappedValue: addPerformanceViewModel)
        _performanceListViewModel = StateObject(wrappedValue: performanceListViewModel)
    }

    var body: some View {
        TabView(selection: $tabSelectionViewModel.selectedTab) {
            NavigationView {
                AddPerformanceView(viewModel: addPerformanceViewModel)
                    .navigationBarTitle("Add Performance")
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Add")
            }.tag(0)
            NavigationView {
                PerformanceListView(viewModel: performanceListViewModel)
                    .navigationBarTitle("Performance List")
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }.tag(1)
        }.environmentObject(tabSelectionViewModel)
    }
}

class TabSelectionViewModel: ObservableObject {
    @Published var selectedTab: Int = 0

    func selectAddTab() {
        selectedTab = 0
    }

    func selectListTab() {
        selectedTab = 1
    }
}
