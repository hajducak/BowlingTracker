import SwiftUI

struct GamesListView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @State private var expandedIndices: Set<Int> = []
    @Namespace private var animationNamespace

    var body: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.games.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    HStack {
                        gameTitle(index: index)
                        Spacer()
                        Image(systemName: "chevron.up.circle.fill")
                            .foregroundColor(Color.orange)
                            .rotationEffect(.degrees(expandedIndices.contains(index) ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: expandedIndices.contains(index))
                    }
                        .padding(.horizontal, Padding.defaultPadding)
                        .tap {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                toggleExpansion(for: index)
                            }
                        }
                    if expandedIndices.contains(index) {
                        ScrollView(.horizontal) {
                            SheetView(game: $viewModel.games[index], showMax: false)
                                .padding(.horizontal, Padding.defaultPadding)
                                .padding(.bottom, Padding.spacingS)
                                .matchedGeometryEffect(id: "sheet\(index)", in: animationNamespace)
                        }
                        .frame(maxHeight: expandedIndices.contains(index) ? .infinity : 0)
                        .clipped()
                        .animation(.easeInOut(duration: 0.3), value: expandedIndices.contains(index))
                    }
                }
                .padding(.bottom, Padding.spacingXXM)
            }
        }
        .padding(.top, Padding.defaultPadding)
    }
    
    private func gameTitle(index: Int) -> some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text("Game #\(index + 1): ")
                .subheading(weight: .regular)
            Text("\(viewModel.games[index].currentScore)")
                .subheading()
        }
    }
    
    private func toggleExpansion(for index: Int) {
        if expandedIndices.contains(index) {
            expandedIndices.remove(index)
        } else {
            expandedIndices.insert(index)
        }
    }
}

#Preview {
    GamesListView(viewModel: .init(
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
    ))
}
