import SwiftUI

struct PreviousGamesView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @State var isCollapsed: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            HStack {
                Text("Previous games")
                    .title()
                Spacer()
                if !viewModel.series.games.isEmpty {
                    Image(systemName: "chevron.up.circle.fill")
                        .foregroundColor(Color(.primary))
                        .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                        .animation(.easeInOut(duration: 0.3), value: isCollapsed)
                }
            }
            .padding(.horizontal, Padding.defaultPadding)
            .tap {
                guard !viewModel.series.games.isEmpty else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }
            if !isCollapsed {
                ForEach(viewModel.series.games.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        GameHeading(
                            gameNumber: index + 1,
                            currentScore: viewModel.series.games[index].currentScore,
                            lane: viewModel.series.games[index].lane,
                            ball: viewModel.userBalls.first(where: { $0.id == viewModel.series.games[index].ballId })
                        )
                            .padding(.horizontal, Padding.defaultPadding)
                        ScrollView(.horizontal) {
                            SheetView(game: $viewModel.series.games[index], showMax: false)
                                .padding(.horizontal, Padding.defaultPadding)
                                .padding(.bottom, Padding.spacingS)
                        }.clipped()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isCollapsed)
            } else {
                previousGamesDescription
                    .padding(.horizontal, Padding.defaultPadding)
            }
        }
    }
    
    var previousGamesDescription: some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text("\(viewModel.series.games.count)")
                .subheading()
            Text(" games with ")
                .subheading(weight: .regular)
            Text(viewModel.series.getSeriesAverage().twoPointFormat())
                .subheading()
            Text(" average so far")
                .subheading(weight: .regular)
        }
    }
}
