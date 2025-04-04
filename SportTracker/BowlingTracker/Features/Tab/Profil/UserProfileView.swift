import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var showEditProfile = false
    
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
