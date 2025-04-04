import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showEditProfile = false
    @State private var isBallPulsing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Padding.spacingM) {
                profileCard
                arsenalSection
            }
        }
        .loadingOverlay(when: $viewModel.isLoading, title: "Loading data...")
        .toast($viewModel.toast, timeout: 3)
        .frame(maxWidth: .infinity)
        .background(Color(.bgPrimary))
        .navigationTitle(viewModel.user?.name ?? "My Profile")
        .navigationBarItems(trailing: editButton)
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(
                name: $viewModel.newProfileName,
                homeCenter: $viewModel.newHomeCenter,
                style: $viewModel.newStyle,
                hand: $viewModel.newHand
            ) {
                viewModel.updateUser()
                showEditProfile = false
            } onClose: {
                showEditProfile = false
            }
        }
    }
    
    var profileCard: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            if let user = viewModel.user {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text(user.email)
                    Spacer()
                }
                user.hand.map { hand in
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text(hand.description)
                        Spacer()
                    }
                }
                user.style.map { style in
                    HStack {
                        Image(systemName: "figure.bowling")
                        Text(style.description)
                        Spacer()
                    }
                }
                user.homeCenter.map { home in
                    HStack {
                        Image(systemName: "pin.fill")
                        Text(home)
                        Spacer()
                    }
                }
            }
        }
        .subheading()
        .frame(maxWidth: .infinity)
        .padding(Padding.spacingXM)
        .background(Color(.bgSecondary))
        .cornerRadius(Corners.corenrRadiusXL, corners: [.bottomLeft, .bottomRight])
        .padding(.horizontal, Padding.defaultPadding)
    }
    
    private var arsenalSection: some View {
        VStack(alignment: .leading, spacing: Padding.spacingM) {
            Text("My Arsenal")
                .title()
            if let user = viewModel.user {
                HStack(spacing: Padding.spacingM) {
                    if user.balls.isNullOrEmpty {
                        ZStack {
                            Circle()
                                .fill(Color(.bgTerciary))
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color(.bgPrimary))
                                .frame(width: 75, height: 75)
                            Circle()
                                .fill(Color(.bgTerciary))
                                .frame(width: 62, height: 62)
                                .scaleEffect(isBallPulsing ? 1.0 : 0.9)
                                .onAppear {
                                    withAnimation(
                                        Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                    ) {
                                        isBallPulsing.toggle()
                                    }
                                }
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color(.primary))
                        }.tap {
                            // TODO: add ball view
                        }
                    }
                    // TODO: mock data
                    BallView(image: Image(.phaze4))
                    BallView(image: Image(.urethane))
                    // TODO: balls
                }
            }
        }.padding(.horizontal, Padding.defaultPadding)
    }
    
    private var editButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showEditProfile = true
            }
        }) {
            HStack {
                Text("Edit")
                    .heading(color: Color(.primary))
                Image(systemName: "pencil.circle")
                    .foregroundColor(Color(.primary))
            }
        }
    }
}

struct BallView: View {
    var image: Image // TODO: remove wehn image will be inside ball struct
    // let ball: Ball
    // let onTap: (Ball) -> ()

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.primary))
                .frame(width: 80, height: 80)
            Circle()
                .fill(Color(.bgPrimary))
                .frame(width: 75, height: 75)
            image // TODO: WebImage(image: ball.image.url)
                .resizable()
                .scaledToFill()
                .frame(width: 62, height: 62)
                .clipShape(Circle())
        }
        // .tap { onTap(ball) }
    }
}
