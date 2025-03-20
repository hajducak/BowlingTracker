import SwiftUI

struct PrimaryButton: View {
    var leadingImage: Image? = nil
    var trailingImage: Image? = nil
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    var isInfinity: Bool = true
    var horizontalPadding: CGFloat = Padding.spacingS
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                leadingImage
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                }
                trailingImage
            }
            .padding(.horizontal, horizontalPadding)
            .infinity(isInfinity)
            .heading(color: isEnabled ? .white : .white.opacity(DefaultOpacity.disabled))
            .frame(height: 48)
            .background(isEnabled ? Color(.primary) : Color(.primaryDisabled))
            .cornerRadius(Corners.corenrRadiusXL)
        }
        .disabled(!isEnabled || isLoading)
        .frame(height: 48)
    }
}

struct SecondaryButton: View {
    var leadingImage: Image? = nil
    var trailingImage: Image? = nil
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    var isInfinity: Bool = true
    var horizontalPadding: CGFloat = Padding.spacingS
    var backgroundColor: Color = Color(.bgPrimary)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                leadingImage
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(.primary)))
                } else {
                    Text(title)
                }
                trailingImage
            }
            .heading(color: isEnabled ? Color(.primary) : Color(.primaryDisabled))
            .padding(.horizontal, horizontalPadding)
            .infinity(isInfinity)
            .frame(height: 48)
            .background(backgroundColor)
            .cornerRadius(Corners.corenrRadiusXL)
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusXL)
                    .stroke(isEnabled ? Color(.primary) : Color(.primaryDisabled), lineWidth: 2)
            )
        }
        .disabled(!isEnabled || isLoading)
        .frame(height: 48)
    }
}

struct SimpleButton: View {
    var leadingImage: Image? = nil
    var trailingImage: Image? = nil
    let title: String
    let isEnabled: Bool
    var isInfinity: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                leadingImage
                Text(title)
                trailingImage
            }
            .custom(size: 16, color: isEnabled ? Color(.darkPrimary) : Color(.darkPrimary).opacity(DefaultOpacity.disabled), weight: .medium)
            .infinity(isInfinity)
            .frame(height: 48)
        }
        .disabled(!isEnabled)
        .frame(height: 48)
    }
}

#Preview {
    VStack {
        PrimaryButton(leadingImage: Image(systemName: "square.and.arrow.up.circle"), title: "With leading image", isLoading: false, isEnabled: true) {}
        PrimaryButton(trailingImage: Image(systemName: "trash.slash.circle"), title: "With trailing image", isLoading: false, isEnabled: true) {}
        PrimaryButton(title: "Enabled", isLoading: false, isEnabled: true) {}
        PrimaryButton(title: "Disabled", isLoading: false, isEnabled: false) {}
        PrimaryButton(title: "Loading", isLoading: true, isEnabled: false) {}
        SecondaryButton(leadingImage: Image(systemName: "square.and.arrow.up.circle"), title: "With leading image", isLoading: false, isEnabled: true) {}
        SecondaryButton(trailingImage: Image(systemName: "trash.slash.circle"), title: "With trailinf image", isLoading: false, isEnabled: true) {}
        SecondaryButton(title: "Enabled", isLoading: false, isEnabled: true) {}
        SecondaryButton(title: "Disabled", isLoading: false, isEnabled: false) {}
        SecondaryButton(title: "Loading", isLoading: true, isEnabled: false) {}
        SimpleButton(title: "Simple enabled", isEnabled: true) {}
        SimpleButton(leadingImage: Image(systemName: "square.and.arrow.up.circle"), title: "Simple image button", isEnabled: true) {}
        SimpleButton(trailingImage: Image(systemName: "trash.slash.circle"), title: "Simple image button", isEnabled: true) {}
        SimpleButton(title: "Simple disabled", isEnabled: false) {}
    }
    .padding(Padding.defaultPadding)
    .background(Color(.bgPrimary))
}
