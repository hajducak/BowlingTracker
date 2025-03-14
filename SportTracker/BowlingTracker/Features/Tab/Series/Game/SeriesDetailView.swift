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
                        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
                            Text(viewModel.series.description)
                                .body()
                                .padding(.horizontal, Padding.defaultPadding)
                            oilPatternLink
                            Text("Current game")
                                .title()
                                .padding(.horizontal, Padding.defaultPadding)
                                .padding(.top, Padding.spacingM)
                            GameView(viewModel: game)
                            PreviousGamesView(viewModel: viewModel)
                                .padding(.top, Padding.spacingM)
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
            Text(viewModel.series.description)
                .body()
                .padding(.horizontal, Padding.defaultPadding)
            oilPatternLink
            if let statistics = viewModel.basicStatisticsViewModel {
                BasicStatisticsView(viewModel: statistics)
                    .padding(.top, Padding.spacingM)
            }
            Text("Games played")
                .title()
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.top, Padding.spacingM)
            GamesListView(viewModel: viewModel)
        }.padding(.bottom, Padding.defaultPadding)
    }
    
    private var empty: some View {
        VStack(spacing: Padding.spacingL) {
            Spacer()
            Text("No games found")
                .title(color: DefaultColor.grey3)
            Spacer()
        }.padding(.horizontal, Padding.defaultPadding)
    }
    
    private var oilPatternLink: some View {
        Group {
            if let oilPatternName = viewModel.series.oilPatternName, !oilPatternName.isEmpty {
                if let oilPatternURL = viewModel.series.oilPatternURL, !oilPatternURL.isEmpty, let url = URL(string: oilPatternURL) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "link.circle")
                            Text(oilPatternName)
                                .multilineTextAlignment(.leading)
                                .body(color: .orange)
                                .underline()
                        }
                    }.padding(.horizontal, Padding.defaultPadding)
                } else {
                    Text("Oil pattern: \(oilPatternName)")
                        .multilineTextAlignment(.leading)
                        .body()
                        .padding(.horizontal, Padding.defaultPadding)
                }
            }
        }
    }
}

#Preview("Finished Series") {
    SeriesDetailView(
        viewModel: .init(
            firebaseService: FirebaseService<Series>(collectionName: CollectionNames.series),
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
        firebaseService: FirebaseService<Series>(collectionName: CollectionNames.series),
        gameViewModelFactory: GameViewModelFactoryImpl(),
        series: Series(name: "Not finished series", tag: .league, games: [])
    ))
}
