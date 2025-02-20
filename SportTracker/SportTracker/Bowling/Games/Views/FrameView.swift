import SwiftUI

struct FrameView: View {
    let frame: Frame
    /// Should count in game model, cose I need previus frames to count the current frame score
    var scoreSoFar: Int?
    var scoreSoFarFormatted: String {
        get {
            guard let scoreSoFar else { return "" }
            return "\(scoreSoFar)"
        }
    }
    var showframeType: Bool = false
    
    var body: some View {
        VStack {
            HStack(spacing: 2) {
                if frame.rolls.count == 0 { emptyBox }
                if frame.frameType == .strike {
                    Text("").frame(width: 20, height: 20)
                }
                ForEach(frame.rolls.indices, id: \.self) { index in
                    formatRoll(frame.rolls[index], index).map {
                        Text($0)
                            .frame(width: 20, height: 20)
                            .background(Color.white)
                            .border(Color.black)
                    }
                }
                if frame.frameType == .unfinished || (frame.index == 10 && frame.rolls.count < 3) {
                    emptyBox
                }
            }
            Text(scoreSoFarFormatted)
                .font(.caption)
                .frame(width: 50, height: 20)
        }
        .overlay {
            if showframeType {
                Text(frame.frameType.rawValue)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .opacity(0.5)
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.2))
        .border(Color.black)
    }
    
    private var emptyBox: some View {
        Text("")
            .frame(width: 20, height: 20)
            .background(Color.white)
            .border(Color.black)
    }

    private func formatRoll(_ roll: Roll,_ index: Int) -> String? {
        let pinCount = roll.knockedDownPins.count == 0 ? "-" : "\(roll.knockedDownPins.count)"
        switch frame.frameType {
        case .strike:
            return "X"
        case .spare:
            return index == 0 ? "\(pinCount)" : "/"
        case .open:
            return "\(pinCount)"
        case .unfinished, .last:
            if index == 0 {
                return roll.knockedDownPins.count == 10 ? "X" : "\(pinCount)"
            } else if index == 1 {
                return roll.knockedDownPins.count == 10 ? "X" : ((frame.rolls[0].knockedDownPins.count + roll.knockedDownPins.count) == 10 ? "/" : "\(pinCount)")
            } else {
                return roll.knockedDownPins.count == 10 ? "X" : ((frame.rolls[1].knockedDownPins.count + roll.knockedDownPins.count) == 10 ? "/" : "\(pinCount)")
            }
        }
    }
    
    private func frameTotalScore(frame: Frame) -> String {
        return "\(frame.rolls.reduce(0) { $0 + $1.knockedDownPins.count })"
    }
}

#Preview {
    VStack(alignment: .leading) {
        Text("Empty frame:")
        HStack {
            FrameView(frame: Frame(rolls: [], index: 1))
            FrameView(frame: Frame(rolls: [Roll.roll1], index: 1), scoreSoFar: 1)
        }
        Text("regular frame:")
        HStack {
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll0], index: 1), scoreSoFar: 8)
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll1], index: 1), scoreSoFar: 9)
            FrameView(frame: Frame(rolls: [Roll.roll5, Roll.roll5], index: 1), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll2], index: 1), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll10], index: 1), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll0, Roll.roll10], index: 1), scoreSoFar: 10)
        }
        Text("10th frame:")
        VStack(alignment: .leading) {
            HStack {
                FrameView(frame: Frame(rolls: [Roll.roll0], index: 10), scoreSoFar: 0)
                FrameView(frame: Frame(rolls: [Roll.roll7], index: 10), scoreSoFar: 7)
                FrameView(frame: Frame(rolls: [Roll.roll7, Roll.roll2], index: 10), scoreSoFar: 9)
                FrameView(frame: Frame(rolls: [Roll.roll7, Roll.roll3], index: 10), scoreSoFar: 10)
                FrameView(frame: Frame(rolls: [Roll.roll10], index: 10), scoreSoFar: 10)
                FrameView(frame: Frame(rolls: [Roll.roll10, Roll.roll10], index: 10), scoreSoFar: 20)
                FrameView(frame: Frame(rolls: [Roll.roll10, Roll.roll10, Roll.roll10], index: 10), scoreSoFar: 30)
            }
            HStack {
                FrameView(frame: Frame(rolls: [Roll.roll10, Roll.roll7, Roll.roll2], index: 10), scoreSoFar: 19)
                FrameView(frame: Frame(rolls: [Roll.roll10, Roll.roll7, Roll.roll3], index: 10), scoreSoFar: 20)
                FrameView(frame: Frame(rolls: [Roll.roll7, Roll.roll3, Roll.roll2], index: 10), scoreSoFar: 12)
                FrameView(frame: Frame(rolls: [Roll.roll7, Roll.roll3, Roll.roll10], index: 10), scoreSoFar: 20)
            }
        }
    }
}
