import SwiftUI

struct AdvancedStatisticsView: View {
    @ObservedObject var viewModel: AdvancedStatisticsViewModel
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            Text(title)
                .title()
                .padding(.horizontal, Padding.defaultPadding)

            HStack(alignment: .center, spacing: 0) {
                let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
                CircularProgressView(
                    percentage: viewModel.strikeAfterStrikePercentage,
                    title: "Strike after strike",
                    size: .init(width: graphSize, height: graphSize),
                    titleModifier: 0.12
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.strikeAfterOpenPercentage,
                    title: "Strike after open",
                    size: .init(width: graphSize, height: graphSize),
                    titleModifier: 0.12
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.cleanGamePercentage,
                    title: "Clean games",
                    description: viewModel.cleanGameCount,
                    size: .init(width: graphSize, height: graphSize),
                    titleModifier: 0.12
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.splitConversionPercentage,
                    title: "Covered splits",
                    description: viewModel.splitConversionCount,
                    size: .init(width: graphSize, height: graphSize),
                    titleModifier: 0.12
                )
            }
            .padding(Padding.defaultPadding)

            LinearProgressView(
                value: viewModel.firstBallAverage,
                maxValue: 10,
                title: "First ball Average",
                width:  UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: 9
            ).padding(.horizontal, Padding.defaultPadding)
        }
    }
}

#Preview {
    AdvancedStatisticsView(viewModel: AdvancedStatisticsViewModel(series: [
        Series(name: "Test Series", tag: .league, games: [
            Game(frames: [
                Frame(rolls: [Roll.roll10], index: 1),
                Frame(rolls: [Roll.roll10], index: 2),
                Frame(rolls: [Roll.roll5, Roll.roll5], index: 3),
                Frame(rolls: [Roll.roll3, Roll.roll4], index: 4),
                Frame(rolls: [Roll.roll10], index: 5),
                Frame(rolls: [Roll.roll10], index: 6),
                Frame(rolls: [Roll.roll2, Roll.roll6], index: 7),
                Frame(rolls: [Roll.roll8, Roll.roll2], index: 8),
                Frame(rolls: [Roll.roll10], index: 9),
                Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10)
            ])
        ])
    ]), title: "Advenced")
}
