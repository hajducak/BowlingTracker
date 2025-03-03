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
            .background(Color.gray.opacity(0.2).cornerRadius(8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
            content.padding(.bottom, 15)
        }
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
}

struct Padding {
    static var defaultPadding: CGFloat = 20
}
