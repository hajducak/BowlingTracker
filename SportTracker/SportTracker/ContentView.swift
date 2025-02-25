import SwiftUI

struct ContentView: View {
//    @StateObject private var addPerformanceViewModel: AddPerformanceViewModel
//    @StateObject private var performanceListViewModel: PerformanceListViewModel
    @StateObject private var bowlingSeriesViewModel: BowlingSeriesViewModel
    @StateObject private var tabSelectionViewModel = TabSelectionViewModel()

    init(
//        addPerformanceViewModel: AddPerformanceViewModel,
//        performanceListViewModel: PerformanceListViewModel,
        bowlingSeriesViewModel: BowlingSeriesViewModel
    ) {
//        _addPerformanceViewModel = StateObject(wrappedValue: addPerformanceViewModel)
//        _performanceListViewModel = StateObject(wrappedValue: performanceListViewModel)
        _bowlingSeriesViewModel = StateObject(wrappedValue: bowlingSeriesViewModel)
    }

    var body: some View {
        TabView(selection: $tabSelectionViewModel.selectedTab) {
//                NavigationView {
//                    AddPerformanceView(viewModel: addPerformanceViewModel)
//                        .navigationBarTitle("Add Performance")
//                }
//                .tabItem {
//                    Image(systemName: "plus.circle.fill")
//                    Text("Add")
//                }.tag(0)
//                NavigationView {
//                    PerformanceListView(viewModel: performanceListViewModel)
//                        .navigationBarTitle("Performance List")
//                }
//                .tabItem {
//                    Image(systemName: "list.dash")
//                    Text("List")
//                }.tag(1)
            NavigationView {
                BowlingSeriesView(viewModel: bowlingSeriesViewModel)
                    .navigationBarTitle("My Series")
            }
            .tabItem {
                Image(systemName: "figure.bowling")
                Text("Bowling")
            }.tag(0)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.stackedLayoutAppearance.normal.iconColor = .white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.stackedLayoutAppearance.selected.iconColor = .blue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.blue]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .environmentObject(tabSelectionViewModel)
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
