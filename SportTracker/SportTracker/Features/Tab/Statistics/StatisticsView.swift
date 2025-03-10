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
            let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
            HStack(alignment: .center, spacing: 0) {
                CircularProgressView(
                    percentage: viewModel.totalStrikesPercentage,
                    title: "Strikes",
                    description: viewModel.totalStrikesCount,
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalSparesPercentage,
                    title: "Spares",
                    description: viewModel.totalSparesCount,
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalOpensPercentage,
                    title: "Opens",
                    description: viewModel.totalOpensCount,
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalSplitsPercentage,
                    title: "Splits",
                    description: viewModel.totalSplitsCount,
                    size: .init(width: graphSize, height: graphSize)
                )
            }
            .padding(.horizontal, Padding.defaultPadding)
            .padding(.vertical, Padding.spacingM)
            LinearProgressView(
                graphIsDisabled: true,
                value: Double(viewModel.totalScore),
                maxValue: Double(viewModel.totalGames * 300),
                title: "Total score:",
                width: UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: lienarGraphLine
            ).padding(.horizontal, Padding.defaultPadding)
            LinearProgressView(
                value: viewModel.totalAvarage,
                maxValue: Double(300),
                title: "Total avarage:",
                width: UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: lienarGraphLine
            ).padding(.horizontal, Padding.defaultPadding)
            Text("TODO: Pins combinations cavarage")
                .padding(.horizontal, Padding.defaultPadding)
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
