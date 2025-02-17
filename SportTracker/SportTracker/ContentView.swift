import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: SportPerformanceViewModel

    init(viewModel: SportPerformanceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView {
            NavigationView {
                AddPerformanceView(viewModel: viewModel)
                    .navigationBarTitle("Add Performance")
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Add")
            }
            NavigationView {
                PerformanceListView(viewModel: viewModel)
                    .navigationBarTitle("Performance List")
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("List")
            }
        }
    }
}
