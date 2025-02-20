import SwiftUI

struct SeriesDetailView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch viewModel.state {
            case .playing(let game):
                VStack(alignment: .leading) {
                    Text("Current Game:")
                        .font(.title3)
                    HStack {
                        Text("current score: \(game.currentScore)")
                        Spacer()
                        Text("max score: \(game.maxPossibleScore)")
                    }
                    Spacer()
                    // TODO: input for current game
                    HStack {
                        Button {
                            // TOOO
                        } label : {
                            Text("Finish series")
                        }
                        Button {
                            // TOOO
                        } label : {
                            Text("New game")
                        }
                    }
                }
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
                    .font(.title3)
                    .foregroundColor(.gray)
                Text("Series avarage: \(viewModel.series.getSeriesAvarage())")
                    .font(.title3)
                    .foregroundColor(.gray)
                List(viewModel.games) { game in
                    GameCell(game: game)
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationTitle(viewModel.series.name)
    }
}

struct GameCell: View {
    let game: Game

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(game.id)
                    .font(.headline)
                Text("Score: \(game.currentScore)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
}
