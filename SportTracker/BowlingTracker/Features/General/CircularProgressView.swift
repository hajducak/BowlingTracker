import SwiftUI

struct CircularProgressView: View {
    var percentage: Double
    var title: String
    var description: String?
    var size: CGSize
    var percentageModifier: CGFloat = 0.24
    var titleModifier: CGFloat = 0.16
    var descriptionModifier: CGFloat = 0.1
    
    @State private var animatedPercentage: Double = 0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color(.border), lineWidth: size.width * 0.12)
                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.darkPrimary),
                                Color(.primary)
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
                        .custom(size: size.width * percentageModifier, weight: .bold)
                        .lineLimit(1)
                    Text(title)
                        .custom(size: size.width * titleModifier, weight: .medium)
                        .multilineTextAlignment(.center)
                    description.map {
                        Text($0).custom(size: size.width * descriptionModifier, weight: .regular)
                            .lineLimit(1)
                    }
                }.padding(.horizontal, Padding.spacingXS)
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
