import SwiftUI
// TODO: use this in entire app
struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .heading(color: .white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .cornerRadius(Corners.corenrRadiusM)
            .background(isEnabled ? Color.orange : Color.orange.opacity(0.3))
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .frame(height: 48)
    }
}
