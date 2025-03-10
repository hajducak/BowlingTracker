import SwiftUI

struct CircularProgressView: View {
    var percentage: Double
    var title: String
    var description: String?
    var size: CGSize

    @State private var animatedPercentage: Double = 0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(DefaultColor.border, lineWidth: size.width * 0.12)
                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.6),
                                Color.orange.opacity(0.8),
                                Color.orange
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: size.width * 0.08, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: animatedPercentage)
                VStack {
                    Text("\(Int(percentage))%")
                        .custom(size: size.width * 0.24, weight: .bold)
                    Text(title)
                        .custom(size: size.width * 0.16, weight: .medium)
                    description.map {
                        Text($0).custom(size: size.width * 0.1, weight: .regular)
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .onAppear { animatedPercentage = percentage }
            .onChange(of: percentage, { _, newPercentage in
                animatedPercentage = newPercentage
            })
        }
    }
}

#Preview {
    CircularProgressView(percentage: 65.32, title: "Test", size: .init(width: 100, height: 100))
}
