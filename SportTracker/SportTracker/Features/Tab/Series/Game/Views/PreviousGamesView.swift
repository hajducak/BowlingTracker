import SwiftUI

struct PreviousGamesView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @State var isCollapsed: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Previous games")
                    .font(.system(size: 24, weight: .bold))
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
                                .padding(.bottom, 8)
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
    
    func gameTitle(at index: Int) -> Text {
        Text("Game #\(index + 1): ")
            .font(.system(size: 14, weight: .medium))
        + Text("\(viewModel.series.games[index].currentScore)")
            .font(.system(size: 16, weight: .bold))
    }
    
    var previousGamesDescription: Text {
        Text("\(viewModel.series.games.count)")
            .font(.system(size: 14, weight: .bold))
        + Text(" games with ")
            .font(.system(size: 14, weight: .regular))
        + Text(String(format: "%.2f%", viewModel.series.getSeriesAvarage()))
            .font(.system(size: 14, weight: .bold))
        + Text(" avarage so far")
            .font(.system(size: 14, weight: .regular))
    }
}
