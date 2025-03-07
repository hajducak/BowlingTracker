import SwiftUI

struct LinearProgressView: View {
    var graphIsDisabled: Bool = false
    var value: Double
    var maxValue: Double
    var title: String
    var width: CGFloat
    var height: CGFloat = 12

    @State private var animatedValue: Double = 0

    var progress: Double {
        max(0, min(animatedValue / maxValue, 1))
    }
    
    var titleDescription: some View {
        HStack(alignment: .center, spacing: Padding.spacingXXXS) {
            Text(title)
                .custom(size: height * 1.5, weight: .medium)
            Text (" \(String(format: "%.2f%", value))")
                .custom(size: height * 1.8, weight: .bold)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            HStack {
                titleDescription
                Spacer()
                Text(String(format: "%.2f%", maxValue))
                    .custom(size: height, color: DefaultColor.grey1)
            }
            if !graphIsDisabled {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: width, height: height)
                        .foregroundColor(DefaultColor.grey6)
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: progress * width, height: height * 0.75)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.6),
                                    Color.orange.opacity(0.8),
                                    Color.orange
                                ]),
                                startPoint: .trailing,
                                endPoint: .leading
                            )
                        )
                        .animation(.easeOut(duration: 1.5), value: animatedValue)
                }
            }
        }
        .frame(width: width)
        .onAppear { animatedValue = value }
    }
}

#Preview {
    LinearProgressView(value: 1500, maxValue: 3000, title: "Progress", width: 300)
}
