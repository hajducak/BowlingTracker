import SwiftUI

struct LinearProgressView: View {
    var value: Double
    var maxValue: Double
    var title: String
    var width: CGFloat
    var height: CGFloat = 12

    @State private var animatedValue: Double = 0

    var progress: Double {
        max(0, min(animatedValue / maxValue, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title + " \(String(format: "%.2f%", value))")
                    .font(.system(size: height * 1.8, weight: .medium))
                Spacer()
                Text(String(format: "%.2f%", maxValue))
                    .foregroundColor(.gray)
                    .font(.system(size: height, weight: .regular))
            }
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .frame(width: width, height: height)
                    .foregroundColor(Color.gray.opacity(0.2))
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
        .frame(width: width)
        .onAppear { animatedValue = value }
    }
}

#Preview {
    LinearProgressView(value: 1500, maxValue: 3000, title: "Progress", width: 300)
}
