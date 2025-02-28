import SwiftUI

struct StrikeShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = UIColor.systemGray6.color
    var innerOffset: CGFloat = 4
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Path { path in
                path.move(to: CGPoint(x: frameSize.width - innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: 0 + innerOffset, y: frameSize.height - innerOffset))
            }.stroke(Color.orange, lineWidth: 3)
            Path { path in
                path.move(to: CGPoint(x: 0 + innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: frameSize.width - innerOffset, y: frameSize.height - innerOffset))
            } .stroke(Color.orange, lineWidth: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct SpareShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = UIColor.systemGray6.color
    var innerOffset: CGFloat = 4
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Path { path in
                path.move(to: CGPoint(x: frameSize.width - innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: 0 + innerOffset, y: frameSize.height - innerOffset))
            }
            .stroke(Color.orange, lineWidth: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct OpenFrameShape: View {
    let number: String
    var frameSize: CGSize = .init(width: 25, height: 25)
    let isSplit: Bool
    var color: Color = UIColor.systemGray6.color
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            if isSplit {
                Circle()
                    .fill(.orange)
            }
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isSplit ? .white : .black)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct MissShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = UIColor.systemGray6.color
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Rectangle()
                .fill(.black)
                .frame(width: 6, height: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}
