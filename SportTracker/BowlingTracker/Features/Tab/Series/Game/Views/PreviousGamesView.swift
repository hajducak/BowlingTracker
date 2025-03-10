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
                Image(systemName: "chevron.up.circle.fill")
                    .foregroundColor(Color.orange)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                    .animation(.easeInOut(duration: 0.3), value: isCollapsed)
            }
            .padding(.horizontal, Padding.defaultPadding)
            .tap {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }
            if !isCollapsed {
                ForEach(viewModel.series.games.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        gameTitle(at: index)
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
    
    func gameTitle(at index: Int) -> some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text("Game #\(index + 1): ")
                .subheading(weight: .regular)
            Text("\(viewModel.series.games[index].currentScore)")
                .heading()
        }
    }
    
    var previousGamesDescription: some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text("\(viewModel.series.games.count)")
                .subheading()
            Text(" games with ")
                .subheading(weight: .regular)
            Text(viewModel.series.getSeriesAvarage().twoPointFormat())
                .subheading()
            Text(" avarage so far")
                .subheading(weight: .regular)
        }
    }
}
