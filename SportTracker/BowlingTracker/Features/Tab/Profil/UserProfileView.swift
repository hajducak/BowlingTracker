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
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color(.bgPrimary))
                .overlay(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color(.bgSecondary))
                            .frame(width: 15, height: 15)
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundStyle(Color(.primary))
                            .frame(width: 15, height: 15)
                    }
                }
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
