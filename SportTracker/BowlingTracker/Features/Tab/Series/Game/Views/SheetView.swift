import SwiftUI

struct SheetView: View {
    @Binding var game: Game
    var showMax: Bool = true

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(game.frames.indices, id: \.self) { index in
                FrameDisplayView(
                    frame: game.frames[index],
                    index: index,
                    game: game,
                    showMax: showMax
                )
            }
        }.padding(.bottom, Padding.spacingS)
    }

    private struct FrameDisplayView: View {
        let frame: Frame
        let index: Int
        let game: Game
        let showMax: Bool
        
        private var firstRoll: Roll? {
            frame.rolls.count >= 1 ? frame.rolls[0] : nil
        }
        
        private var secondRoll: Roll? {
            frame.rolls.count >= 2 ? frame.rolls[1] : nil
        }
        
        private var thirdRoll: Roll? {
            frame.rolls.count >= 3 ? frame.rolls[2] : nil
        }
        
        private var isOpen: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) < 10
        }
        
        private var isSpare: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) < 10 && 
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) == 10
        }
        
        private var isStrike: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) == 20
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                FrameView(
                    frame: frame,
                    scoreSoFar: frame.frameType == .unfinished ? nil : game.cumulativeScoreForFrame(at: index),
                    maxPossibleScore: frame.frameType == .unfinished && showMax ? game.maxPossibleScore : nil
                )
                .border(Color(.bgSecondary), width: 0.5)
                
                if index != 9 {
                    PinDisplayView(
                        firstRollPins: frame.rolls.first?.knockedDownPins,
                        secondRollPins: frame.rolls.last?.knockedDownPins
                    )
                } else {
                    TenthFramePinDisplayView(frame: frame)
                }
            }
        }
    }

    private struct PinDisplayView: View {
        var firstRollPins: [Pin]?
        var secondRollPins: [Pin]?
        
        var isLeadingEmpty: Bool = false
        var isTrailingEmpty: Bool = false
        
        var body: some View {
            HStack(spacing: FrameView.boxSpacing) {
                if isLeadingEmpty { emptyBox }
                MiniPinView(
                    firstRollPins: firstRollPins,
                    secondRollPins: secondRollPins
                )
                if isTrailingEmpty { emptyBox }
            }
            .padding(.vertical, 6)
            .frame(width: width)
            .background(Color(.bgTerciary))
            .border(Color(.bgSecondary), width: 0.5)
        }

        private var emptyBox: some View {
            Text("")
                .frame(width: FrameView.boxSize.width, height: FrameView.boxSize.height)
                .background(Color(.bgTerciary))
        }
        
        private var width: CGFloat {
            let plusLeading = isLeadingEmpty ? FrameView.boxSpacing + FrameView.boxSize.width : 0
            let plusTrailing = isTrailingEmpty ? FrameView.boxSpacing + FrameView.boxSize.width : 0
            let bacisWidth = 2 * FrameView.boxPadding + FrameView.boxSize.width * 2 + FrameView.boxSpacing
            return bacisWidth + plusTrailing + plusLeading
        }
    }

    private struct TenthFramePinDisplayView: View {
        let frame: Frame
        
        private var firstRoll: Roll? {
            frame.rolls.count >= 1 ? frame.rolls[0] : nil
        }
        
        private var secondRoll: Roll? {
            frame.rolls.count >= 2 ? frame.rolls[1] : nil
        }
        
        private var thirdRoll: Roll? {
            frame.rolls.count >= 3 ? frame.rolls[2] : nil
        }
        
        private var isOpen: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) < 10
        }
        
        private var isSpare: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) < 10 && 
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) == 10
        }
        
        private var isStrike: Bool {
            (firstRoll?.knockedDownPins.count ?? 0) + (secondRoll?.knockedDownPins.count ?? 0) == 20
        }
        
        var body: some View {
            HStack(spacing: 0) {
                if isOpen {
                    pinView(firstRoll: firstRoll, secondRoll: secondRoll)
                } else if isSpare {
                    pinView(firstRoll: firstRoll, secondRoll: secondRoll, isTrailingEmpty: thirdRoll?.knockedDownPins.count == 10)
                    if thirdRoll?.knockedDownPins.count != 10 {
                        pinView(firstRoll: thirdRoll, secondRoll: nil)
                    }
                } else if isStrike {
                    pinView(firstRoll: thirdRoll, secondRoll: nil, isLeadingEmpty: true)
                } else {
                    pinView(firstRoll: secondRoll, secondRoll: thirdRoll, isLeadingEmpty: true)
                }
            }
        }
        
        private func pinView(firstRoll: Roll?, secondRoll: Roll?, isTrailingEmpty: Bool = false, isLeadingEmpty: Bool = false) -> some View {
            PinDisplayView(
                firstRollPins: firstRoll?.knockedDownPins,
                secondRollPins: secondRoll?.knockedDownPins,
                isLeadingEmpty: isLeadingEmpty,
                isTrailingEmpty: isTrailingEmpty
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading, content: {
        ScrollView(.horizontal) {
            SheetView(
                game: .constant(Game(frames: [
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
                ]))
            )
        }
        ScrollView(.horizontal) {
            SheetView(
                game: .constant(Game(frames: [
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
                ]))
            )
        }
        ScrollView(.horizontal) {
            SheetView(
                game: .constant(Game(frames: [
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
                ]))
            )
        }
    })
}
