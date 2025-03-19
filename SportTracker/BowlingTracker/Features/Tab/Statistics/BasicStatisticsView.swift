import SwiftUI

struct BasicStatisticsView: View {
    @ObservedObject var viewModel: BasicStatisticsViewModel
    
    private let lienarGraphLine: CGFloat = 9
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
            Text("Statistics")
                .title()
                .padding(.horizontal, Padding.defaultPadding)
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
            .padding(Padding.defaultPadding)
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
        }
        .background(Color(.bgPrimary))
    }
}
