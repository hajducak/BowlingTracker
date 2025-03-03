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
            .tap {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }
            if !isCollapsed {
                ForEach(viewModel.series.games.indices, id: \.self) { index in
                    Text("Game #\(index + 1): ")
                        .font(.system(size: 14, weight: .medium))
                    + Text("\(viewModel.series.games[index].currentScore)")
                        .font(.system(size: 16, weight: .bold))
                }
                .animation(.easeInOut(duration: 0.3), value: isCollapsed)
            } else {
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
    }
}
