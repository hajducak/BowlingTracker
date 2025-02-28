import SwiftUI

struct FrameView: View {
    let frame: Frame
    var scoreSoFar: Int?
    var scoreSoFarFormatted: String {
        get {
            guard let scoreSoFar else { return "" }
            return "\(scoreSoFar)"
        }
    }
    var showframeType: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(frame.index)")
                .font(.caption).bold()
                .frame(width: 58)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .border(Color.black)
            VStack {
                HStack(spacing: 2) {
                    if frame.rolls.count == 0 { emptyBox }
                    if frame.frameType == .strike {
                        Text("").frame(width: 20, height: 20)
                    }
                    ForEach(frame.rolls.indices, id: \.self) { index in
                        formatRoll(frame.rolls[index], index).map {
                            Text($0)
                                .foregroundColor(frame.isSplitFrame && index == 0 ? .white : .black)
                                .frame(width: 20, height: 20)
                                .border(Color.black)
                                .background(frame.isSplitFrame && index == 0 ? Color.orange : Color.white)
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
            .padding(4)
            .background(Color.gray.opacity(0.2))
            .border(Color.black)
        }
    }
    
    private var emptyBox: some View {
        Text("")
            .frame(width: 20, height: 20)
            .background(Color.white)
            .border(Color.black)
    }

    private func formatRoll(_ roll: Roll,_ index: Int) -> String? {
        let lastRollPinCount = roll.knockedDownPins.count
        let pinCount = lastRollPinCount == 0 ? "-" : "\(lastRollPinCount)"
        switch frame.frameType {
        case .strike: return "X"
        case .spare: return index == 0 ? pinCount : "/"
        case .open: return pinCount
        case .unfinished, .last:
            let firstRollPins = frame.rolls.first?.knockedDownPins.count ?? 0
            let secondRollPins = frame.rolls.indices.contains(1) ? frame.rolls[1].knockedDownPins.count : 0
            switch index {
            case 0: return lastRollPinCount.isTen ? "X" : pinCount
            case 1:
                return lastRollPinCount.isTen && firstRollPins.isTen ? "X" :
                    ((firstRollPins + lastRollPinCount).isTen && lastRollPinCount != 0 ? "/" : pinCount)
            default:
                return lastRollPinCount.isTen ? "X" :
                    ((secondRollPins + lastRollPinCount).isTen && firstRollPins.isTen ? "/" : pinCount)
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
