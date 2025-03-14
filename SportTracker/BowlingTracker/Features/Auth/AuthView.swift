import SwiftUI

struct AuthView: View {
    @StateObject var viewModel: AuthViewModel
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Padding.spacingL) {
                Spacer()
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                
                Text("Bowling Tracker")
                    .title(color: .primary)
                
                VStack(spacing: Padding.spacingM) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle()
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle()
                        .textContentType(isRegistering ? .newPassword : .password)
                    
                    Toggle("Remember me", isOn: $viewModel.shouldRememberCredentials)
                        .tint(Color.orange)
                        .heading()
                }
                
                VStack(spacing: Padding.spacingS) {
                    PrimaryButton(
                        title: isRegistering ? "Sign Up" : "Sign In",
                        isLoading: viewModel.isLoading,
                        isEnabled: !(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
                    ) {
                        if isRegistering {
                            viewModel.signUp()
                        } else {
                            viewModel.signIn()
                        }
                    }
                    Button(action: {
                        withAnimation {
                            isRegistering.toggle()
                        }
                    }) {
                        Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .heading(color: .orange)
                    }
                }
                Spacer()
            }
            .padding(Padding.defaultPadding)
            .navigationBarHidden(true)
            .background(Color(.lightOrange))
        }
        .toast($viewModel.toast, timeout: 3)
    }
} 
