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
            if let basicStatisticsViewModel = viewModel.basicStatisticsViewModel {
                BasicStatisticsView(viewModel: basicStatisticsViewModel)
            }
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading series...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .toast($viewModel.toast, timeout: 3)
    }
}
