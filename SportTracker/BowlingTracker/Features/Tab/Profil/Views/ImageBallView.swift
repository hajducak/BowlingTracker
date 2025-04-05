import SwiftUI

struct ImageBallView: View {
    let ball: Ball
    let onTap: (Ball) -> ()

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(.primary))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color(.bgPrimary))
                    .frame(width: 75, height: 75)
                AsyncImage(url: ball.imageUrl, transaction: Transaction(animation: .default)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(.primary)))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 62, height: 62)
                            .clipShape(Circle())
                    case .failure:
                        Image(.defaultBall)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 62, height: 62)
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }
                .id("\(ball.id)-\(ball.imageUrl?.absoluteString ?? "")")
            }.overlay(alignment: .topLeading) {
                if ball.isSpareBall ?? false {
                    Text("Spare")
                        .smallNegative()
                        .padding(.horizontal, Padding.spacingXS)
                        .padding(.vertical, Padding.spacingXXS)
                        .background(Color(.complementary))
                        .cornerRadius(Corners.corenrRadiusS, corners: [.topRight, .bottomLeft])
                        .cornerRadius(Corners.corenrRadiusXXS, corners: [.topLeft, .bottomLeft])
                        .offset(x: -Padding.spacingS, y: Padding.spacingXXM)
                }
            }
            Text(ball.name)
                .subheading(color: Color(.primary))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(maxWidth: 84, minHeight: 40)
        }
        .tap { onTap(ball) }
    }
}
