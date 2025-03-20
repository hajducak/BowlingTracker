import SwiftUI

struct SheetView: View {
    @Binding var game: Game
    var showMax: Bool = true

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(game.frames.indices, id: \.self) { index in
                FrameDisplayView(frame: game.frames[index], index: index, game: game, showMax: showMax)
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
                .border(Color(.bgSecondary), width: 1)
                .padding(.leading, -2)
                
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
        
        var body: some View {
            MiniPinView(
                firstRollPins: firstRollPins,
                secondRollPins: secondRollPins
            )
            .padding(6)
            .background(Color(.bgTerciary))
            .border(Color(.bgSecondary), width: 1)
            .padding(.leading, -2)
            .padding(.top, -1)
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
                    Spacer()
                } else if isSpare {
                    pinView(firstRoll: firstRoll, secondRoll: secondRoll)
                    if thirdRoll?.knockedDownPins.count != 10 {
                        pinView(firstRoll: thirdRoll, secondRoll: nil)
                    } else {
                        Spacer()
                    }
                } else if isStrike {
                    Spacer()
                    pinView(firstRoll: thirdRoll, secondRoll: nil)
                } else {
                    Spacer()
                    pinView(firstRoll: secondRoll, secondRoll: thirdRoll)
                }
            }
        }
        
        private func pinView(firstRoll: Roll?, secondRoll: Roll?) -> some View {
            PinDisplayView(
                firstRollPins: firstRoll?.knockedDownPins,
                secondRollPins: secondRoll?.knockedDownPins
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading, content: {
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
    })
}
