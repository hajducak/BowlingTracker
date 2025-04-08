import SwiftUI

struct BallDetailView: View {
    @ObservedObject var viewModel: BallViewModel
    @State var imageSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Padding.spacingS) {
                if let imageUrl = viewModel.imageUrl,
                   let coreImageUrl = viewModel.coreImageUrl
                {
                    ImageComparisonSlider(
                        firstImage: imageUrl,
                        secondImage: coreImageUrl,
                        firstImageId: imageUrl.absoluteString,
                        secondImageId: coreImageUrl.absoluteString,
                        size: imageSize
                    )
                    .padding(.top, Padding.spacingM)
                } else if let imageUrl = viewModel.imageUrl {
                    BallAsyncImage(
                        imageUrl: imageUrl,
                        ballId: imageUrl.absoluteString,
                        size: imageSize
                    )
                } else {
                    Image(.defaultBall)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .clipShape(Circle())
                }
                Spacer()
                
            }
            .infinity(true)
            .padding(.horizontal, Padding.defaultPadding)
            .navigationTitle(viewModel.name)
            .navigationBarItems(
                leading:
                    Button(action: {
                        viewModel.close()
                    }, label: {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(Color(.primary))
                            Text("Close")
                                .heading(color: Color(.primary))
                        }
                    })
            ).background(Color(.bgPrimary))
        }
    }
}

#Preview {
    BallDetailView(
        viewModel: BallViewModel(
            ball: Ball(
                id: "1",
                imageUrl: URL(string: "https://hammerbowling.com/cdn/shop/files/Purple_Pearl_Urethane_CG_1600x1707_website.png?v=1709760600&width=1800"),
                name: "Purple Pearl Urethane ",
                brand: "Hammer",
                coverstock: "Urethane Pearl",
                rg: 2.650,
                diff: 0.015,
                surface: "500, 1000, 2000 Siaair Micro Pad",
                weight: 15,
                core: "Symmetric - LED",
                coreImageUrl: URL(string: "https://hammerbowling.com/cdn/shop/products/Purple_Pearl_Urethane_Core_16-15_1920x1980_06f9937e-969d-428c-a0b1-f3fcfcdf84a3.jpg?v=1709760600&width=1800"),
                pinToPap: 2.3,
                layout: "20-30-40",
                lenght: 55,
                backend: 40,
                hook: 5,
                isSpareBall: false
            )
        )
    )
}
