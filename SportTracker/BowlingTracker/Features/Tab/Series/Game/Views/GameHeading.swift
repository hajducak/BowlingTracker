import SwiftUI

struct GameHeading: View {
    var gameNumber: Int
    var currentScore: Int
    var lane: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text("Game #\(gameNumber): ")
                .subheading(weight: .regular)
            Text("\(currentScore)")
                .heading()
            lane.map { lane in
                HStack(spacing: 0) {
                    Text("on lane #")
                        .subheading(weight: .regular)
                    Text(lane).subheading()
                }
                .padding(.leading, Padding.spacingXS)
            }
        }
    }
}
