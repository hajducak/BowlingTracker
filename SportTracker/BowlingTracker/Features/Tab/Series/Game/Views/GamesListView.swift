import SwiftUI

struct GamesListView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @State private var expandedIndices: Set<Int> = []
    @Namespace private var animationNamespace

    var body: some View {
        ForEach(viewModel.games.indices, id: \.self) { index in
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    GameHeading(
                        gameNumber: index + 1,
                        currentScore: viewModel.games[index].currentScore,
                        lane: viewModel.games[index].lane,
                        ball: viewModel.games[index].ball
                    )
                    Spacer()
                    Image(systemName: "chevron.up.circle.fill")
                        .foregroundColor(Color(.primary))
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
    
    private func toggleExpansion(for index: Int) {
        if expandedIndices.contains(index) {
            expandedIndices.remove(index)
        } else {
            expandedIndices.insert(index)
        }
    }
}
