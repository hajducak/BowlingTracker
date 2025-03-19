import SwiftUI

struct ContentView: View {
    @StateObject private var bowlingSeriesViewModel: SeriesViewModel
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @StateObject private var tabSelectionViewModel = TabSelectionViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    init(bowlingSeriesViewModel: SeriesViewModel, statisticsViewModel: StatisticsViewModel) {
        _bowlingSeriesViewModel = StateObject(wrappedValue: bowlingSeriesViewModel)
        _statisticsViewModel = StateObject(wrappedValue: statisticsViewModel)
    }

    var body: some View {
        TabView(selection: $tabSelectionViewModel.selectedTab) {
            NavigationView {
                SeriesView(viewModel: bowlingSeriesViewModel)
                    .navigationBarTitle("My Series")
                    .navigationBarItems(leading: signOutButton)
            }
            .tabItem {
                Image(systemName: "figure.bowling")
                Text("My Series")
            }.tag(0)
            
            NavigationView {
                StatisticsView(viewModel: statisticsViewModel)
                    .navigationBarTitle("My Statistics")
                    .navigationBarItems(leading: signOutButton)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Statistics")
            }.tag(1)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(.bgSecondary)
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(.textPrimary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.textPrimary)]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(.primary))
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(.primary))]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .environmentObject(tabSelectionViewModel)
    }

    var signOutButton: some View {
        Button(action: {
            authViewModel.signOut()
        }) {
            Image(systemName: "arrowshape.turn.up.backward.circle")
                .foregroundColor(Color(.primary))
            Text("Sign out")
                .heading(color: Color(.primary))
        }
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
