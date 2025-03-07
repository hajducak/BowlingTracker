import SwiftUI

struct SeriesCell: View {
    var series: Series
    var onDeleteSeries: (Series) -> Void
    @State private var isPulsing = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(series.name)
                    .heading()
                    .padding(.top, 15)
                if !series.description.isEmpty {
                    Text(series.description)
                        .subheading(weight: .regular)
                }
                HStack {
                    Text(series.formattedDate)
                    Text("games: \(series.games.count)")
                }.caption()
            }
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .foregroundColor(.orange)
        }
        .flexWidthModifier(alignment: .leading)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(UIColor.systemGray6.color, lineWidth: 1)
                HStack {
                    Text(series.tag.rawValue)
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(series.tag.color)
                        .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                        .cornerRadius(2, corners: [.topLeft, .topRight])
                    if series.currentGame != nil {
                        HStack {
                            Image(systemName: "livephoto.play")
                                .scaleEffect(isPulsing ? 1.2 : 1.0)
                            Text("Live")
                        }
                            .foregroundColor(.white)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(.red)
                            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                            .cornerRadius(2, corners: [.topLeft, .topRight])
                            .onAppear {
                                withAnimation(
                                    Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                ) {
                                    isPulsing.toggle()
                                }
                            }
                    }
                }.offset(x: 16, y: -2)
            }
        )
        .padding(.horizontal, 20)
        // .tap(count: 3) { onDeleteSeries(series) }
    }
}

#Preview {
    VStack {
        SeriesCell(series: Series(name: "Tournament", tag: .tournament)) { _ in }
        SeriesCell(series: Series(name: "League", tag: .league)) { _ in }
        SeriesCell(series: Series(name: "Training", tag: .training)) { _ in }
        SeriesCell(series: Series(name: "Camp", tag: .other)) { _ in }
    }
}

extension SeriesType {
    var color: Color {
        switch self {
        case .tournament:
            return .red
        case .league:
            return .orange
        case .training:
            return .yellow
        case .other:
            return UIColor.systemGray4.color
        }
    }
}
