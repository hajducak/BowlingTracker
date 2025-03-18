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
            .heading(color: .white)
            .frame(height: 48)
            .cornerRadius(Corners.corenrRadiusM)
            .background(isEnabled ? Color.orange : Color.orange.opacity(0.3))
            .cornerRadius(12)
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                leadingImage
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                } else {
                    Text(title)
                }
                trailingImage
            }
            .heading(color: isEnabled ? Color.orange : Color.orange.opacity(0.3))
            .padding(.horizontal, horizontalPadding)
            .infinity(isInfinity)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(Corners.corenrRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusM)
                    .stroke(isEnabled ? Color.orange : Color.orange.opacity(0.3), lineWidth: 1)
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
            .custom(size: 16, color: isEnabled ? Color.orange : Color.orange.opacity(0.3), weight: .medium)
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
    }.padding(Padding.defaultPadding)
}
