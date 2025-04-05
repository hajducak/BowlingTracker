import SwiftUI

struct ContentView: View {
    @StateObject private var bowlingSeriesViewModel: SeriesViewModel
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @StateObject private var userProfileViewModel: UserProfileViewModel

    @StateObject private var tabSelectionViewModel = TabSelectionViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    init(
        bowlingSeriesViewModel: SeriesViewModel,
        statisticsViewModel: StatisticsViewModel,
        userProfileViewModel: UserProfileViewModel)
    {
        _bowlingSeriesViewModel = StateObject(wrappedValue: bowlingSeriesViewModel)
        _statisticsViewModel = StateObject(wrappedValue: statisticsViewModel)
        _userProfileViewModel = StateObject(wrappedValue: userProfileViewModel)
    }

    var body: some View {
        TabView(selection: $tabSelectionViewModel.selectedTab) {
            NavigationView {
                SeriesView(viewModel: bowlingSeriesViewModel)
                    .navigationBarTitle("My Series")
            }
            .tabItem {
                Image(systemName: "figure.bowling.circle.fill")
                Text("My Series")
            }.tag(0)
            
            NavigationView {
                StatisticsView(viewModel: statisticsViewModel)
                    .navigationBarTitle("My Statistics")
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                Text("Statistics")
            }.tag(1)
            
            NavigationView {
                UserProfileView(viewModel: userProfileViewModel)
                    .navigationBarTitle("My Profile")
                    .navigationBarItems(leading: signOutButton)
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }.tag(2)
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
