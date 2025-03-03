import SwiftUI

struct FrameView: View {
    let frame: Frame
    var scoreSoFar: Int?
    var scoreSoFarFormatted: String {
        get {
            guard let scoreSoFar else { return "0" }
            return "\(scoreSoFar)"
        }
    }
    var maxPossibleScore: Int?
    var showframeType: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(frame.index)")
                .font(.system(size: 12, weight: .bold))
                .frame(width: max(65, CGFloat(frame.index != 10 ? frame.rolls.count : 3) * 32.5))
                .padding(.vertical, 4)
                .background(UIColor.systemGray6.color)
            HStack(spacing: 3) {
                if frame.rolls.count == 0 { emptyBox }
                if frame.frameType == .strike {
                    Text("").frame(width: 25, height: 25)
                }
                ForEach(frame.rolls.indices, id: \.self) { index in
                    formatRoll(frame.rolls[index], index)
                }
                if frame.frameType == .unfinished || (frame.index == 10 && frame.rolls.count < 3) {
                    emptyBox
                }
            }.padding(3)
            if let score = maxPossibleScore, frame.index == 10 {
                Text("\(score)")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.bottom, 3)
            } else {
                Text(scoreSoFarFormatted)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.bottom, 3)
            }
        }
        .background(.white)
        .border(UIColor.systemGray6.color, width: 2)
    }
    
    private var emptyBox: some View {
        Text("")
            .frame(width: 25, height: 25)
            .background(Color.white)
            .border(UIColor.systemGray6.color, width: 2)
    }

    private func formatRoll(_ roll: Roll,_ index: Int) -> some View {
        let lastRollPinCount = roll.knockedDownPins.count
        let pinCountView = lastRollPinCount == 0 ? AnyView(MissShape()) : AnyView(OpenFrameShape(
            number: "\(lastRollPinCount)",
            isSplit: frame.isSplitRoll(for: index)
        ))
        switch frame.frameType {
        case .strike: return AnyView(StrikeShape())
        case .spare: return index == 0 ? pinCountView : AnyView(SpareShape())
        case .open: return pinCountView
        case .unfinished, .last:
            let firstRollPins = frame.rolls.first?.knockedDownPins.count ?? 0
            let secondRollPins = frame.rolls.indices.contains(1) ? frame.rolls[1].knockedDownPins.count : 0
            switch index {
            case 0: return lastRollPinCount.isTen ? AnyView(StrikeShape()) : pinCountView
            case 1:
                return lastRollPinCount.isTen && firstRollPins.isTen ? AnyView(StrikeShape()) :
                    ((firstRollPins + lastRollPinCount).isTen && lastRollPinCount != 0 ? AnyView(SpareShape() ): pinCountView)
            default:
                return lastRollPinCount.isTen ? AnyView(StrikeShape()) :
                    ((secondRollPins + lastRollPinCount).isTen && firstRollPins.isTen ? AnyView(SpareShape()) : pinCountView)
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
            FrameView(frame: Frame(rolls: [Roll.roll1], index: 2), scoreSoFar: 1)
            FrameView(frame: Frame(rolls: [
                Roll.init(knockedDownPins: [
                    Pin(id: 1), Pin(id: 2), Pin(id: 3), Pin(id: 4), Pin(id: 5), Pin(id: 6), Pin(id: 8), Pin(id: 9)
                ])
            ], index: 1))
        }
        Text("regular frame:")
        HStack {
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll0], index: 1), scoreSoFar: 8)
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll1], index: 2), scoreSoFar: 9)
            FrameView(frame: Frame(rolls: [Roll.roll5, Roll.roll5], index: 3), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll8, Roll.roll2], index: 4), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll10], index: 5), scoreSoFar: 10)
            FrameView(frame: Frame(rolls: [Roll.roll0, Roll.roll10], index: 6), scoreSoFar: 10)
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

fileprivate extension Int {
    var isTen: Bool {
        self == 10
    }
}

extension UIColor {
    var color: Color {
        Color(self)
    }
}
