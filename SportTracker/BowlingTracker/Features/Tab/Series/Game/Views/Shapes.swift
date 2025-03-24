import SwiftUI

struct StrikeShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = Color(.bgSecondary)
    var innerOffset: CGFloat = Padding.spacingXS
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Path { path in
                path.move(to: CGPoint(x: frameSize.width - innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: 0 + innerOffset, y: frameSize.height - innerOffset))
            }.stroke(Color(.primary), lineWidth: 3)
            Path { path in
                path.move(to: CGPoint(x: 0 + innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: frameSize.width - innerOffset, y: frameSize.height - innerOffset))
            } .stroke(Color(.primary), lineWidth: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct SpareShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = Color(.bgSecondary)
    var innerOffset: CGFloat = Padding.spacingXS
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Path { path in
                path.move(to: CGPoint(x: frameSize.width - innerOffset, y: 0 + innerOffset))
                path.addLine(to: CGPoint(x: 0 + innerOffset, y: frameSize.height - innerOffset))
            }
            .stroke(Color(.primary), lineWidth: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct OpenFrameShape: View {
    let number: String
    var frameSize: CGSize = .init(width: 25, height: 25)
    let isSplit: Bool
    var color: Color = Color(.bgSecondary)
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            if isSplit {
                Circle()
                    .fill(Color(.primary))
            }
            Text(number)
                .heading(color: isSplit ? .forcedWhite : .textPrimary)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}

struct MissShape: View {
    var frameSize: CGSize = .init(width: 25, height: 25)
    var color: Color = Color(.bgSecondary)
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            Rectangle()
                .fill(.textPrimary)
                .frame(width: 6, height: 3)
        }.frame(width: frameSize.width, height: frameSize.height)
    }
}
