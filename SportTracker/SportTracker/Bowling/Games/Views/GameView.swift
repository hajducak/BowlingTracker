import SwiftUI

struct GameView: View {
    @State var game: Game
    var showMax: Bool = true

    var body: some View {
        HStack(alignment: .bottom) {
            ForEach(game.frames.indices, id: \.self) { index in
                FrameView(
                    frame: game.frames[index],
                    scoreSoFar: game.frames[index].frameType == .unfinished ? nil : game.cumulativeScoreForFrame(at: index)
                )
            }
            if showMax {
                VStack(alignment: .center, spacing: 8) {
                    Text("MAX")
                    Text("\(game.maxPossibleScore)")
                        .bold()
                }
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .border(Color.black)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, content: {
        GameView(
            game: Game(frames: [
                Frame(rolls: [Roll.roll10], index: 1),
                Frame(rolls: [Roll.roll10], index: 2),
                Frame(rolls: [Roll.roll10], index: 3),
                Frame(rolls: [Roll.roll10], index: 4),
                Frame(rolls: [Roll.roll10], index: 5),
                Frame(rolls: [Roll.roll10], index: 6),
                Frame(rolls: [Roll.roll10], index: 7),
                Frame(rolls: [Roll.roll10], index: 8),
                Frame(rolls: [Roll.roll10], index: 9),
                Frame(rolls: [Roll.roll10,
                              Roll.roll10,
                              Roll.roll10], index: 10)
            ])
        )
        GameView(
            game: Game(frames: [
                Frame(rolls: [Roll.roll7, Roll.roll3], index: 1),
                Frame(rolls: [Roll.roll6, Roll.roll4], index: 2),
                Frame(rolls: [Roll.roll5, Roll.roll5], index: 3),
                Frame(rolls: [Roll.roll4, Roll.roll6], index: 4),
                Frame(rolls: [Roll.roll3, Roll.roll7], index: 5),
                Frame(rolls: [Roll.roll2, Roll.roll8], index: 6),
                Frame(rolls: [Roll.roll1, Roll.roll9], index: 7),
                Frame(rolls: [Roll.roll0, Roll.roll10], index: 8),
                Frame(rolls: [Roll.roll8, Roll.roll2], index: 9),
                Frame(rolls: [Roll.roll9, Roll.roll0], index: 10)
            ])
        )
        GameView(
            game: Game(frames: [
                Frame(rolls: [Roll.roll7, Roll.roll3], index: 1),
                Frame(rolls: [Roll.roll6, Roll.roll4], index: 2),
                Frame(rolls: [Roll.roll5, Roll.roll5], index: 3),
                Frame(rolls: [Roll.roll4, Roll.roll6], index: 4),
                Frame(rolls: [Roll.roll3, Roll.roll7], index: 5),
                Frame(rolls: [Roll.roll2, Roll.roll8], index: 6),
                Frame(rolls: [], index: 7),
                Frame(rolls: [], index: 8),
                Frame(rolls: [], index: 9),
                Frame(rolls: [], index: 10)
            ])
        )
    })
}
