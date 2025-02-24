import SwiftUI

struct SeriesDetailView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch viewModel.state {
            case .playing(let game):
                ScrollView {
                    HStack(spacing: 4) {
                        ForEach(viewModel.series.games.indices, id: \.self) { index in
                            Text("Game #\(index): \(viewModel.series.games[index].currentScore)")
                        }
                    }
                    Text("Current Game:")
                        .font(.title3)
                    RollView(viewModel: game)
                }.navigationBarItems(
                    trailing:
                        Button(action: {
                            viewModel.saveSeries()
                        }, label: {
                            Text("Save")
                        })
                )
            case .empty:
                VStack {
                    Spacer()
                    Text("No games found")
                        .font(.title)
                        .foregroundColor(.gray)
                    Spacer()
                }
            case .content:
                Text("Series score: \(viewModel.series.getSeriesScore())")
                    .font(.title2)
                Text("Series avarage: " + String(format: "%.2f%", viewModel.series.getSeriesAvarage()))
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Strikes: " + String(format: "%.2f%%", viewModel.series.getSeriesStrikePercentage()))
                    Text("Spares: " + String(format: "%.2f%%", viewModel.series.getSeriesSparePercentage()))
                    Text("Opens: " + String(format: "%.2f%%", viewModel.series.getSeriesOpenPercentage()))
                }
                .font(.title3)
                .foregroundColor(.gray)
                // TODO: do circle graphs from statistics
                ScrollView(.vertical) {
                    ForEach(viewModel.games.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("Game #\(index + 1): \(viewModel.games[index].currentScore)")
                            ScrollView(.horizontal) {
                                GameView(game: $viewModel.games[index], showMax: false)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationTitle(viewModel.series.name)
    }
}

#Preview("Finished Series") {
    SeriesDetailView(
        viewModel: .init(
            firebaseManager: FirebaseManager.shared,
            series:  Series(id: UUID().uuidString, name: "Finished Series", tag: .league, games: [
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
                ]),
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
                ]),
                Game(frames: [
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 1),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 2),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 3),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 4),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 5),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 6),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 7),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 8),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins)], index: 9),
                    Frame(rolls: [Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins), Roll.init(knockedDownPins: Roll.tenPins)], index: 10)
                ])
            ], currentGame: nil)
        )
    ).navigationTitle("1. liga ABL")
}

#Preview("Current Game") {
    SeriesDetailView(viewModel: .init(
        firebaseManager: FirebaseManager.shared,
        series: Series(id: UUID().uuidString, name: "Not finished series", tag: .league, games: [])
    ))
}
