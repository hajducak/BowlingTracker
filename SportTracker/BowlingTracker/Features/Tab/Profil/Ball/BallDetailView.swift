import SwiftUI

struct BallDetailView: View {
    @ObservedObject var viewModel: BallViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var maxImageSize: CGSize = CGSize(width: 300, height: 300)
    @State private var minImageSize: CGSize = CGSize(width: 80, height: 80)
    
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
                                Text("Ball info").tag(BallViewContentType.info)
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
                    {
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
        }
    }
    
    var contentInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(title: "Brand", value: viewModel.brand ?? "N/A")
            infoRow(title: "Coverstock", value: viewModel.coverstock ?? "N/A")
            infoRow(title: "Core", value: viewModel.core ?? "N/A")
            infoRow(title: "Surface", value: viewModel.surface ?? "N/A")
            infoRow(title: "RG", value: viewModel.rg != nil ? "\(viewModel.rg!)" : "N/A")
            infoRow(title: "Differential", value: viewModel.diff != nil ? "\(viewModel.diff!)" : "N/A")
            infoRow(title: "Weight", value: "\(viewModel.weight) lb")
            infoRow(title: "Layout", value: viewModel.layout ?? "N/A")
            
            VStack(alignment: .leading, spacing: 8) {
                statBar(title: "Length", value: viewModel.lenght ?? 0, maxValue: 100)
                statBar(title: "Backend", value: viewModel.backend ?? 0, maxValue: 100)
                statBar(title: "Hook Potential", value: viewModel.hook ?? 0, maxValue: 10)
            }
            
            // TODO: remove - Adding more content to enable scrolling
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 80)
                    .cornerRadius(8)
                    .overlay(Text("Additional content \(i+1)"))
            }
        }
    }
    
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(Color(.primary))
            
            Spacer()
        }
    }

    var contentStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
                .padding(.top)
            
            // TODO: remove - Adding more content to enable scrolling
            ForEach(0..<10) { i in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 80)
                    .cornerRadius(8)
                    .overlay(Text("Statistics block \(i+1)"))
            }
        }
    }
    
    func statBar(title: String, value: Int, maxValue: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(value)/\(maxValue)")
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                        .cornerRadius(5)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(value) / CGFloat(maxValue), height: 10)
                        .cornerRadius(5)
                }
            }
            .frame(height: 10)
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
