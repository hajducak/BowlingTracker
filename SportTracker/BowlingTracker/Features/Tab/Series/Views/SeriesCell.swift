import SwiftUI

struct SeriesCell: View {
    var series: Series
    var onDeleteSeries: (Series) -> Void
    @State private var isPulsing = false

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
            Text(series.name)
                .heading()
                .padding(.top, Padding.spacingM)
            if !series.description.isEmpty {
                Text(series.description)
                    .subheading(weight: .regular)
            }
            VStack(alignment: .leading, spacing: Padding.spacingXXS) {
                Text("Games: \(series.games.count)")
                Text("Avarage: \(series.getSeriesAvarage().twoPointFormat())")
                if let oilPatternName = series.oilPatternName, !oilPatternName.isEmpty {
                    Text("Oil pattern: \(oilPatternName)").multilineTextAlignment(.trailing)
                }
                Text("at \(series.formattedDate)")
            }.caption()
        }
        .flexWidthModifier(alignment: .leading)
        .padding(Padding.spacingS)
        .background(Color.white)
        .cornerRadius(Corners.corenrRadiusM)
        .overlay(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Corners.corenrRadiusM)
                    .stroke(DefaultColor.border, lineWidth: 1)
                HStack {
                    Text(series.tag.rawValue)
                        .smallNegative()
                        .padding(.horizontal, Padding.spacingXS)
                        .padding(.vertical, Padding.spacingXXS)
                        .background(series.tag.color)
                        .cornerRadius(Corners.corenrRadiusS, corners: [.bottomLeft, .bottomRight])
                        .cornerRadius(Corners.corenrRadiusXXS, corners: [.topLeft, .topRight])
                    if series.currentGame != nil {
                        HStack {
                            Image(systemName: "livephoto.play")
                                .scaleEffect(isPulsing ? 1.2 : 1.0)
                            Text("Live")
                        }
                            .smallNegative()
                            .padding(.horizontal, Padding.spacingXS)
                            .padding(.vertical, Padding.spacingXXS)
                            .background(.red)
                            .cornerRadius(Corners.corenrRadiusS, corners: [.bottomLeft, .bottomRight])
                            .cornerRadius(Corners.corenrRadiusXXS, corners: [.topLeft, .topRight])
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
        .padding(.horizontal, Padding.defaultPadding)
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
            return DefaultColor.grey4
        }
    }
}
