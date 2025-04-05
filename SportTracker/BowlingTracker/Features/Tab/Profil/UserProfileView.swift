import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showEditProfile = false
    @State private var showAddBall = false
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
                viewModel.updateUserProfile()
                showEditProfile = false
            } onClose: {
                showEditProfile = false
            }
        }.fullScreenCover(isPresented: $showAddBall) {
            AddBallView(
                title: "Add new ball",
                name: $viewModel.newBallName,
                brand: $viewModel.newBallBrand,
                imageURL: $viewModel.newBallImageUrl,
                weight: $viewModel.newBallWeight,
                rg: $viewModel.newBallRg,
                diff: $viewModel.newBallDiff,
                pinToPap: $viewModel.newBallPinToPap,
                layout: $viewModel.newBallLayout,
                coreImageUrl: $viewModel.newBallCoreImageUrl,
                core: $viewModel.newBallCore,
                surface: $viewModel.newBallSurface,
                coverstock: $viewModel.newBallCoverstock,
                lenght: $viewModel.newBallLenght,
                backend: $viewModel.newBallBackend,
                hook: $viewModel.newBallHook
            ) {
                viewModel.addNewBall()
                showAddBall = false
            } onClose: {
                showAddBall = false
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
                .padding(.horizontal, Padding.defaultPadding)
            if let user = viewModel.user {
                ScrollView {
                    HStack(alignment: .top, spacing: Padding.spacingM) {
                        addBall
                        if let balls = user.balls {
                            ForEach(balls) { ball in
                                BallView(ball: ball, onTap: { _ in
                                    // TODO: Ball detial
                                })
                            }
                        }
                    }.padding(.horizontal, Padding.defaultPadding)
                }
            }
        }
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
    
    private var addBall: some View {
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
            Image(systemName: "plus")
                .foregroundColor(Color(.primary))
                .title()
        }.tap { showAddBall = true }
    }
}

struct BallView: View {
    let ball: Ball
    let onTap: (Ball) -> ()

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(.primary))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color(.bgPrimary))
                    .frame(width: 75, height: 75)
                AsyncImage(url: ball.imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(.primary)))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 62, height: 62)
                            .clipShape(Circle())
                    case .failure:
                        Image(.defaultBall)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 62, height: 62)
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text(ball.name)
                .heading(color: Color(.primary))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 84)
        }
        .tap { onTap(ball) }
    }
}
