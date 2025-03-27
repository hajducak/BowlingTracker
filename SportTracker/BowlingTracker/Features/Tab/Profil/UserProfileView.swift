import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Padding.spacingM) {
                profileCard
                Text("My Arsenal")
                    .title()
                    .padding(.horizontal, Padding.defaultPadding)
            }
        }
        .loadingOverlay(when: $viewModel.isLoading, title: "Loading data...")
        .toast($viewModel.toast, timeout: 3)
        .frame(maxWidth: .infinity)
        .background(Color(.bgPrimary))
        .navigationTitle("My Profile")
    }
    
    var profileCard: some View {
        HStack(alignment: .top) {
            Image(.profilePhoto) // TODO: image from profile
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 140)
                .clipShape(
                    CustomCornerRectangle(topLeft: Corners.corenrRadiusExtraLarge, topRight: Corners.corenrRadiusXL, bottomLeft: Corners.corenrRadiusXL, bottomRight: Corners.corenrRadiusXL)
                )
            
            // TODO: made placeholder
//            Image(systemName: "person.crop.circle")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80, height: 80)
//                .foregroundStyle(Color(.bgPrimary))
//                .overlay(alignment: .topTrailing) {
//                    ZStack {
//                        Circle()
//                            .fill(Color(.bgSecondary))
//                            .frame(width: 15, height: 15)
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .foregroundStyle(Color(.primary))
//                            .frame(width: 15, height: 15)
//                    }
//                }.background {
//                    RoundedRectangle(cornerRadius: Corners.corenrRadiusXL)
//                        .stroke(Color(.bgTerciary), lineWidth: 2)
//                        .frame(height: 130)
//                        .cornerRadius(Corners.corenrRadiusExtraLarge, corners: [.topLeft])
//                }
            VStack(alignment: .leading, spacing: Padding.spacingS) {
                if let user = viewModel.user {
                    Text(user.name ?? "Marek Hajdučák") // TODO: ass navigation title ???
                        .title()
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text(user.email)
                    }.subheading()
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text(user.hand ?? "Righty")
                    }.subheading()
                    HStack {
                        Image(systemName: "figure.bowling")
                        Text(user.style ?? "Two handed")
                    }.subheading()
                    HStack {
                        Image(systemName: "pin.fill")
                        Text(user.homeCenter ?? "Academy Bowling Žilina")
                    }.subheading()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(Padding.spacingXM)
        .background(Color(.bgSecondary))
        .cornerRadius(Corners.corenrRadiusXL, corners: [.bottomLeft, .bottomRight, .topRight])
        .cornerRadius(Corners.corenrRadiusExtraLarge, corners: [.topLeft])
        .padding(.horizontal, Padding.defaultPadding)
    }
}

struct CustomCornerRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: topLeft, y: 0))
        path.addLine(to: CGPoint(x: rect.width - topRight, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: topRight),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - bottomRight, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: bottomLeft, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - bottomLeft),
            control: CGPoint(x: 0, y: rect.height)
        )
        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addQuadCurve(
            to: CGPoint(x: topLeft, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        return path
    }
}

extension View {
    func customCornerRadius(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) -> some View {
        clipShape(CustomCornerRectangle(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        ))
    }
}
