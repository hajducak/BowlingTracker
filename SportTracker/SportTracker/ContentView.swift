import SwiftUI

struct ContentView: View {
    @StateObject private var addPerformanceViewModel: AddPerformanceViewModel
    @StateObject private var performanceListViewModel: PerformanceListViewModel

    init(
        addPerformanceViewModel: AddPerformanceViewModel,
        performanceListViewModel: PerformanceListViewModel
    ) {
        _addPerformanceViewModel = StateObject(wrappedValue: addPerformanceViewModel)
        _performanceListViewModel = StateObject(wrappedValue: performanceListViewModel)
    }

    var body: some View {
        TabView {
            NavigationView {
                AddPerformanceView(viewModel: addPerformanceViewModel)
                    .navigationBarTitle("Add Performance")
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Add")
            }
            NavigationView {
                PerformanceListView(viewModel: performanceListViewModel)
                    .navigationBarTitle("Performance List")
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
        }
    }
}
