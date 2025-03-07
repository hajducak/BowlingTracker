import SwiftUI

struct FlexWidthModifier: ViewModifier {
    let alignment: Alignment
    init(alignment: Alignment = .center) {
        self.alignment = alignment
    }
    func body(content: Content) -> some View {
        content.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
}

struct HideTabBarModifier: ViewModifier {
    @Binding var isHidden: Bool
    func body(content: Content) -> some View {
        content
            .toolbar(isHidden ? .hidden : .visible, for: .tabBar)
    }
}

struct CustomTextFieldStyle: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 50)
            .background(Color.white.cornerRadius(Corners.corenrRadiusS))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusS)
                    .stroke(DefaultColor.border, lineWidth: 1)
            )
            .labled(label: label)
    }
}

struct LoadingOverlayModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Saving game...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    }.background(Color.gray.opacity(0.3))
                }
            }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}


struct LabeledStyle: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            Text(label)
                .heading()
            content.padding(.bottom, 15)
        }
    }
}

struct DefaultBorderModifier: ViewModifier {
    var lineWith: CGFloat = 2
    func body(content: Content) -> some View {
        content.border(DefaultColor.border, width: lineWith)
    }
}

extension View {
    @ViewBuilder
    func tap(count: Int = 1, perform: @escaping () -> Void) -> some View {
        contentShape(Rectangle())
            .onTapGesture(count: count, perform: perform)
    }
    
    func flexWidthModifier(alignment: Alignment = .center) -> some View {
        modifier(FlexWidthModifier(alignment: alignment))
    }
    
    func hideTabBar(when isHidden: Binding<Bool>) -> some View {
        modifier(HideTabBarModifier(isHidden: isHidden))
    }

    func textFieldStyle(labeled: String) -> some View {
        modifier(CustomTextFieldStyle(label: labeled))
    }
    
    func labled(label: String) -> some View {
        modifier(LabeledStyle(label: label))
    }
    
    func loadingOverlay(when isLoading: Binding<Bool>) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// default border color with default line width
    /// - color: UIColor.systemgray6
    /// - lineWith: 2
    func defaultBorder(lineWith: CGFloat = 2) -> some View {
        modifier(DefaultBorderModifier(lineWith: lineWith))
    }
}
