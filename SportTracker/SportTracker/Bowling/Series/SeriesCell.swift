import SwiftUI

struct SeriesCell: View {
    var series: Series
    var onDeleteSeries: (Series) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(series.tag.rawValue)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.blue.cornerRadius(8))
            Text(series.name)
                .padding(.bottom, 6)
            HStack {
                Text(series.formattedDate)
                Spacer()
                Text("games: \(series.games.count)")
            }
            .font(.callout)
            .foregroundColor(.gray)
            .padding(.bottom, 6)
        }
        .flexWidthModifier(alignment: .leading)
        .padding(.horizontal, 20)
        .tap(count: 3) {
            onDeleteSeries(series)
        }
    }
}

#Preview {
    SeriesCell(series: Series(id: "1", name: "Test name", tag: .tournament)) { _ in }
}
