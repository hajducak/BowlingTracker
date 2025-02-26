import SwiftUI

struct ContentView: View {
    @StateObject private var bowlingSeriesViewModel: BowlingSeriesViewModel
    @StateObject private var tabSelectionViewModel = TabSelectionViewModel()

    init(bowlingSeriesViewModel: BowlingSeriesViewModel) {
        _bowlingSeriesViewModel = StateObject(wrappedValue: bowlingSeriesViewModel)
    }

    var body: some View {
        TabView(selection: $tabSelectionViewModel.selectedTab) {
            NavigationView {
                BowlingSeriesView(viewModel: bowlingSeriesViewModel)
                    .navigationBarTitle("My Series")
            }
            .tabItem {
                Image(systemName: "figure.bowling")
                Text("Bowling")
            }.tag(0)
            
            NavigationView {
                Text("TODO")
                    .navigationBarTitle("My statistics")
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }.tag(1)
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
