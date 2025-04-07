import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showEditProfile = false
    @State private var showAddBall = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Padding.spacingM) {
                userProfileInfo
                arsenalSection
            }
        }
        .loadingOverlay(when: $viewModel.isLoading, title: "Loading data...")
        .toast($viewModel.toast, timeout: 3)
        .frame(maxWidth: .infinity)
        .background(Color(.bgPrimary))
        .navigationTitle(viewModel.user?.name ?? "My Profile")
        .navigationBarItems(trailing: editButton)
        .fullScreenCover(item: $viewModel.selectedBall) { ballViewModel in
            BallDetailView(viewModel: ballViewModel)
        }
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
                isSpareBall: $viewModel.newBallIsSpareBall,
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
                viewModel.showAddBallModal = false
            } onClose: {
                showAddBall = false
                viewModel.showAddBallModal = false
            }
        }.onReceive(viewModel.$showAddBallModal) { value in
            if value { showAddBall = true }
        }
    }
    
    var userProfileInfo: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            if let user = viewModel.user {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text(user.email)
                    Spacer()
                }
                user.homeCenter.map { home in
                    HStack {
                        Image(systemName: "pin.fill")
                        Text(home)
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
                user.hand.map { hand in
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text(hand.description)
                        Spacer()
                    }
                }
            }
        }
        .subheading(weight: .medium)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Padding.defaultPadding)
    }
    
    private var arsenalSection: some View {
        VStack(alignment: .leading, spacing: Padding.spacingM) {
            HStack {
                Text("My Arsenal")
                    .title()
                Spacer()
                Button {
                    showAddBall = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color(.primary))
                }
            }.padding(.horizontal, Padding.defaultPadding)
            if let user = viewModel.user {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Padding.spacingM) {
                        if user.balls.isNillOrEmpty {
                            EmptyBallView() {
                                showAddBall = true
                            }
                        }
                        if let balls = user.balls {
                            ForEach(balls) { ball in
                                ImageBallView(ball: ball, onTap: { viewModel.openDetail($0) })
                            }
                        }
                    }
                    .padding(.horizontal, Padding.defaultPadding)
                    .padding(.bottom, Padding.spacingXM)
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
}
