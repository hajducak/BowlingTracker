import SwiftUI

struct SeriesDetailView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                switch viewModel.state {
                case .playing(let game):
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(viewModel.series.description)
                                .subheading(weight: .regular)
                                .padding(.horizontal, Padding.defaultPadding)
                            Text("Current game")
                                .title()
                                .padding(.horizontal, Padding.defaultPadding)
                            GameView(viewModel: game)
                            PreviousGamesView(viewModel: viewModel)
                                .padding(.top, Padding.spacingXXM)
                        }.padding(.bottom, Padding.defaultPadding)
                    }
                    .navigationBarItems(
                        trailing:
                            Button(action: {
                                viewModel.saveSeries()
                            }, label: {
                                Text("Save")
                                    .heading(color: .orange)
                            })
                    )
                    .onReceive(viewModel.$shouldDismiss) { if $0 { dismiss() }}
                    .loadingOverlay(when: $viewModel.savingIsLoading)
                case .empty: empty
                case .content: content
                }
            }
            .navigationTitle(viewModel.series.name)
            .toast($viewModel.toast, timeout: 3)
            .navigationBarItems(
                leading:
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }.heading(color: .orange)
                    })
            )
        }
        .accentColor(.orange)
        .navigationBarBackButtonHidden()
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
            Text(viewModel.series.description)
                .subheading(weight: .regular)
                .padding(.horizontal, Padding.defaultPadding)
            Text("Statistics")
                .title()
                .padding(.horizontal, Padding.defaultPadding)
            HStack(alignment: .center, spacing: 0) {
                CircularProgressView(
                    percentage: viewModel.series.getSeriesStrikePercentage(),
                    title: "Strikes",
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.series.getSeriesSparePercentage(),
                    title: "Spares",
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.series.getSeriesOpenPercentage(),
                    title: "Opens",
                    size: .init(width: graphSize, height: graphSize)
                )
                Spacer()
                CircularProgressView(
                    percentage: viewModel.series.getSeriesSplitPercentage(),
                    title: "Splits",
                    size: .init(width: graphSize, height: graphSize)
                )
            }
            .padding(Padding.defaultPadding)
            LinearProgressView(
                graphIsDisabled: true,
                value: Double(viewModel.series.getSeriesScore()),
                maxValue: Double(viewModel.series.games.count * 300),
                title: "Series score:",
                width: UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: 9
            ).padding(.horizontal, Padding.defaultPadding)
            LinearProgressView(
                value: Double(viewModel.series.getSeriesAvarage()),
                maxValue: Double(300),
                title: "Series avarage:",
                width: UIScreen.main.bounds.width - Padding.defaultPadding * 2,
                height: 9
            ).padding(.horizontal, Padding.defaultPadding)
            Text("Games played")
                .title()
                .padding([.horizontal, .top], Padding.defaultPadding)
            GamesListView(viewModel: viewModel)
        }.padding(.bottom, Padding.defaultPadding)
    }
    
    private var empty: some View {
        VStack {
            Spacer()
            Text("No games found")
                .title()
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview("Finished Series") {
    SeriesDetailView(
        viewModel: .init(
            firebaseManager: FirebaseManager.shared,
            gameViewModelFactory: GameViewModelFactoryImpl(),
            series:  Series(name: "Finished Series", tag: .league, games: [
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
        gameViewModelFactory: GameViewModelFactoryImpl(),
        series: Series(name: "Not finished series", tag: .league, games: [])
    ))
}
