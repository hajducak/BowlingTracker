import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    private let lienarGraphLine: CGFloat = 9
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            FilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.bottom, Padding.spacingS)
            HStack(spacing: 0) {
                Text("Total games:")
                    .custom(size: lienarGraphLine * 1.5, weight: .medium)
                Text(" \(viewModel.totalGames)")
                    .custom(size: lienarGraphLine * 1.8, weight: .bold)
                Spacer()
            }.padding(.horizontal, Padding.defaultPadding)
            ScrollView {
                VStack(spacing: Padding.spacingM) {
                    if let basicStatisticsViewModel = viewModel.basicStatisticsViewModel {
                        BasicStatisticsView(viewModel: basicStatisticsViewModel, title: nil)
                    }
                    if let averagesViewModel = viewModel.averagesViewModel {
                        SeriesAverageView(viewModel: averagesViewModel, title: "Averages")
                    }
                    if let advancedStaticticsViewModel = viewModel.advancedStaticticsViewModel {
                        AdvancedStatisticsView(viewModel: advancedStaticticsViewModel, title: "Advanced")
                    }
                    if let pinCoverageViewModel = viewModel.pinCoverageViewModel {
                        PinCoverageView(viewModel: pinCoverageViewModel, title: "Pin coverage")
                    }
                }
                Spacer().frame(height: Padding.defaultPadding)
            }
            .refreshable {
                viewModel.refresh()
            }
        }
        .background(Color(.bgPrimary))
        .loadingOverlay(when: $viewModel.isLoading, title: "Loading series...")
        .frame(maxWidth: .infinity)
        .toast($viewModel.toast, timeout: 3)
    }
}
