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
            Text (" \(value.twoPointFormat())")
                .custom(size: height * 1.8, weight: .bold)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            HStack {
                titleDescription
                Spacer()
                Text(maxValue.twoPointFormat())
                    .custom(size: height, color: Color(.textSecondary))
            }
            if !graphIsDisabled {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: width, height: height)
                        .foregroundColor(Color(.border))
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: progress * width, height: height * 0.75)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.darkPrimary),
                                    Color(.primary)
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
        .onChange(of: value, { _, newValue in
            animatedValue = newValue
        })
    }
}

#Preview {
    LinearProgressView(value: 1500, maxValue: 3000, title: "Progress", width: 300)
}
