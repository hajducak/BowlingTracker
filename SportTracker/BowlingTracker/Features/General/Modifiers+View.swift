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

struct InfinityModifier: ViewModifier {
    var isInfinity: Bool
    func body(content: Content) -> some View {
        if isInfinity {
            content
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

struct CustomTextFieldStyle: ViewModifier {
    var label: String? = nil
    var borderWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(Color(.textPrimary))
            .frame(height: 50)
            .background(Color(.bgSecondary).cornerRadius(Corners.corenrRadiusS))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusS)
                    .stroke(Color(.border), lineWidth: borderWidth)
            )
            .labled(label: label)
    }
}

struct LoginTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(Color(.textPrimary))
            .frame(height: 50)
            .background(Color(.bgAuth).cornerRadius(Corners.corenrRadiusS))
            .overlay(
                RoundedRectangle(cornerRadius: Corners.corenrRadiusS)
                    .stroke(Color(.borderAuth), lineWidth: 1)
            )
    }
}

struct LoadingOverlayModifier: ViewModifier {
    @Binding var isLoading: Bool
    var title: String
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView(title)
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    }.background(Color(.bgTerciary))
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
    var label: String?
    func body(content: Content) -> some View {
        if let label {
            VStack(alignment: .leading, spacing: Padding.spacingS) {
                Text(label)
                    .heading()
                content.padding(.bottom, 15)
            }
        } else {
            content
        }
    }
}

struct DefaultBorderModifier: ViewModifier {
    var lineWith: CGFloat = 2
    func body(content: Content) -> some View {
        content.border(Color(.border), width: lineWith)
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

    func defaultTextFieldStyle(labeled: String? = nil, borderWidth: CGFloat = 0) -> some View {
        modifier(CustomTextFieldStyle(label: labeled, borderWidth: borderWidth))
    }
    
    func loginTextFieldStyle() -> some View {
        modifier(LoginTextFieldStyle())
    }
    
    func labled(label: String?) -> some View {
        modifier(LabeledStyle(label: label))
    }
    
    func loadingOverlay(when isLoading: Binding<Bool>, title: String) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, title: title))
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// default border color with default line width
    /// - color: .border
    /// - lineWith: 2
    func defaultBorder(lineWith: CGFloat = 2) -> some View {
        modifier(DefaultBorderModifier(lineWith: lineWith))
    }
    
    func infinity(_ isInfinity: Bool) -> some View {
        modifier(InfinityModifier(isInfinity: isInfinity))
    }
}

extension Double {
    func twoPointFormat() -> String {
        String(format: "%.2f%", self)
    }
}
