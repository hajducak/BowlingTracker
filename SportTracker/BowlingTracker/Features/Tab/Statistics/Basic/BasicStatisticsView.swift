import SwiftUI

struct BasicStatisticsView: View {
    @ObservedObject var viewModel: BasicStatisticsViewModel
    var title: String?
    private let lienarGraphLine: CGFloat = 9
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
            title.map {
                Text($0)
                    .title()
                    .padding(.horizontal, Padding.defaultPadding)
            }
            if let text = viewModel.tooltipText {
                InfoBox(info: text)
                    .multilineTextAlignment(.leading)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    ))
            }
            HStack(alignment: .center, spacing: 0) {
                CircularProgressView(
                    percentage: viewModel.totalStrikesPercentage,
                    title: "Strikes",
                    description: viewModel.totalStrikesCount,
                    size: .init(width: graphSize, height: graphSize),
                    onLongPress: {
                        viewModel.showTooltip(for: .strikes)
                    }, onTap: {
                        viewModel.dismissTooltipIfShowing()
                    }
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalSparesPercentage,
                    title: "Spares",
                    description: viewModel.totalSparesCount,
                    size: .init(width: graphSize, height: graphSize),
                    onLongPress: {
                        viewModel.showTooltip(for: .spares)
                    }, onTap: {
                        viewModel.dismissTooltipIfShowing()
                    }
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalOpensPercentage,
                    title: "Opens",
                    description: viewModel.totalOpensCount,
                    size: .init(width: graphSize, height: graphSize),
                    onLongPress: {
                        viewModel.showTooltip(for: .opens)
                    }, onTap: {
                        viewModel.dismissTooltipIfShowing()
                    }
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.totalSplitsPercentage,
                    title: "Splits",
                    description: viewModel.totalSplitsCount,
                    size: .init(width: graphSize, height: graphSize),
                    onLongPress: {
                        viewModel.showTooltip(for: .splits)
                    }, onTap: {
                        viewModel.dismissTooltipIfShowing()
                    }
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
                value: viewModel.totalAverage,
                maxValue: Double(300),
                title: "Total average:",
                width: UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: lienarGraphLine
            ).padding(.horizontal, Padding.defaultPadding)
        }
        .background(Color(.bgPrimary))
    }
}
