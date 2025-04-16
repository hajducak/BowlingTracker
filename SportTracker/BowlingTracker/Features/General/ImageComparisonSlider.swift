import SwiftUI

struct ImageComparisonSlider: View {
    let firstImage: URL
    let secondImage: URL
    let firstImageId: String
    let secondImageId: String
    @State private var sliderPosition: CGFloat = 0.3
    let size: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                BallAsyncImage(
                    imageUrl: firstImage,
                    ballId: firstImageId,
                    size: size
                )
                BallAsyncImage(
                    imageUrl: secondImage,
                    ballId: secondImageId,
                    size: size
                )
                .clipShape(
                    Rectangle()
                        .path(in: CGRect(
                            x: 0,
                            y: 0,
                            width: geometry.size.width * sliderPosition,
                            height: geometry.size.height
                        ))
                )
                Rectangle()
                    .fill(Color(.primary))
                    .frame(width: 2, height: geometry.size.height)
                    .offset(x: geometry.size.width * sliderPosition)
                Circle()
                    .fill(Color(.primary))
                    .frame(width: 30, height: 30)
                    .overlay(
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Image(systemName: "chevron.right")
                        }.custom(size: 8, color: Color(.bgPrimary), weight: .medium)
                    )
                    .offset(x: geometry.size.width * sliderPosition - 15)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPosition = value.location.x / geometry.size.width
                                sliderPosition = min(max(newPosition, 0), 1)
                            }
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(width: size.width, height: size.height)
    }
}
