import Kingfisher
import SwiftUI

struct BallAsyncImage: View {
    var imageUrl: URL?
    var ballId: String?
    var size: CGSize

    var body: some View {
        KFImage(imageUrl)
            .placeholder {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(.primary)))
                    .frame(width: size.width, height: size.height)
            }
            .cancelOnDisappear(true)
            .cacheOriginalImage()
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipShape(Circle())
            .id(ballId)
    }
}
