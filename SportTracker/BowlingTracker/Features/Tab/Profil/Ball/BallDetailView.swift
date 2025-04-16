import SwiftUI

struct BallDetailView: View {
    @ObservedObject var viewModel: BallViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var maxImageSize: CGSize = CGSize(width: 300, height: 300)
    @State private var minImageSize: CGSize = CGSize(width: 80, height: 80)
    @State private var animateRows = false
    
    private var imageSize: CGSize {
        let maxScrollForAnimation: CGFloat = 200
        let progress = min(max(scrollOffset / maxScrollForAnimation, 0), 1)
        
        let width = maxImageSize.width - (maxImageSize.width - minImageSize.width) * progress
        let height = maxImageSize.height - (maxImageSize.height - minImageSize.height) * progress

        return CGSize(width: width, height: height)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(.bgPrimary).ignoresSafeArea()
                ScrollViewReader { proxy in
                    ScrollView {
                        GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                self.scrollOffset = -geometry.frame(in: .named("scrollView")).origin.y
                            }
                            return Color.clear
                        }
                        .frame(height: 0)
                        Color.clear.frame(height: maxImageSize.height + Padding.spacingL)
                        VStack(alignment: .leading, spacing: Padding.spacingS) {
                            Picker("", selection: $viewModel.contentType) {
                                Text("Ball information").tag(BallViewContentType.info)
                                Text("Statistics").tag(BallViewContentType.statistics)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .heading()
                            switch viewModel.contentType {
                            case .info: contentInfo
                            case .statistics: contentStatistics
                            }
                        }
                        .padding(.horizontal, Padding.defaultPadding)
                    }
                    .coordinateSpace(name: "scrollView")
                    .infinity(true)
                }
                
                VStack {
                    if let imageUrl = viewModel.imageUrl,
                       let coreImageUrl = viewModel.coreImageUrl
                    { // TODO: disable slider when scrolling down and image is smaller and smaller
                        ImageComparisonSlider(
                            firstImage: imageUrl,
                            secondImage: coreImageUrl,
                            firstImageId: imageUrl.absoluteString,
                            secondImageId: coreImageUrl.absoluteString,
                            size: imageSize
                        )
                        .padding(.vertical, Padding.spacingM)
                    } else if let imageUrl = viewModel.imageUrl {
                        BallAsyncImage(
                            imageUrl: imageUrl,
                            ballId: imageUrl.absoluteString,
                            size: imageSize
                        )
                        .padding(.vertical, Padding.spacingM)
                    } else {
                        Image(.defaultBall)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .clipShape(Circle())
                            .padding(.vertical, Padding.spacingM)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.bgPrimary))
                .animation(.interpolatingSpring(stiffness: 120, damping: 14), value: imageSize)
                .zIndex(1)
            }
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
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animateRows = true
                    }
                }
            }
        }
    }
    
    var contentInfo: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            infoRow(title: "Brand", value: viewModel.brand ?? "N/A")
            infoRow(title: "Coverstock", value: viewModel.coverstock ?? "N/A")
            infoRow(title: "Core", value: viewModel.core ?? "N/A")
            infoRow(title: "Surface", value: viewModel.surface ?? "N/A")
            infoRow(title: "RG", value: viewModel.rg != nil ? "\(viewModel.rg!)" : "N/A")
            infoRow(title: "Diff", value: viewModel.diff != nil ? "\(viewModel.diff!)" : "N/A")
            infoRow(title: "Weight", value: "\(viewModel.weight) lb")
            infoRow(title: "Layout", value: viewModel.layout ?? "N/A")
            infoRow(title: "Lenght", value: "\(viewModel.lenght ?? 0)")
            infoRow(title: "Backend", value: "\(viewModel.backend ?? 0)")
            infoRow(title: "Hook", value:  "\(viewModel.hook ?? 0)")
        }.padding(.top, Padding.spacingM)
    }
    
    func infoRow(title: String, value: String) -> some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                DiagonalShape()
                    .fill(Color(.complementary))
                    .frame(width: 120)
                    .shadow(color: Color(.bgSecondary).opacity(0.8), radius: 3, x: 2, y: 0)
                Text(title)
                    .custom(size: 16, color: .textPrimaryInverse, weight: .bold)
                    .padding(.leading, Padding.spacingXM)
            }
            .frame(height: 35)
            .zIndex(1)
            ZStack(alignment: .leading) {
                ReverseConnectionShape()
                    .fill(Color(.bgTerciary))
                    .frame(maxWidth: .infinity)
                Text(value)
                    .body()
                    .padding(.trailing, Padding.spacingXM)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(height: 35)
            .offset(x: animateRows ? 0 : -300)
        }
        .cornerRadius(4)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    var contentStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
                .padding(.top)
            // TODO:
        }
    }
}

struct DiagonalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let connectionOffset: CGFloat = 15
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - connectionOffset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct ReverseConnectionShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let connectionOffset: CGFloat = 15
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: -connectionOffset, y: 0))
        path.closeSubpath()
        return path
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
