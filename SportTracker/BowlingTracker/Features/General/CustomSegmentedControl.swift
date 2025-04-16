import SwiftUI

struct CustomSegmentedControl<Content: View>: View {
    let segments: [String]
    @Binding var selectedIndex: Int
    let content: (Int) -> Content
    private let animationDuration: Double = 0.3
    private let animationSpringDamping: Double = 0.7
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<segments.count, id: \.self) { index in
                    segmentButton(
                        title: segments[index],
                        isSelected: selectedIndex == index,
                        action: { selectedIndex = index }
                    )
                }
            }
            .cornerRadius(Corners.corenrRadiusS)
            
            GeometryReader { geometry in
                let segmentWidth = geometry.size.width / CGFloat(segments.count)
                let offset = CGFloat(selectedIndex) * segmentWidth
                
                Rectangle()
                    .fill(Color(.primary))
                    .frame(width: segmentWidth, height: 3)
                    .offset(x: offset)
                    .animation(.spring(response: animationDuration, dampingFraction: animationSpringDamping), value: selectedIndex)
            }
            .frame(height: 3)
            .zIndex(1)
            Rectangle()
                .fill(Color(.bgTerciary))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .offset(y: -1)
                .zIndex(0)
            content(selectedIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: animationDuration), value: selectedIndex)
        }
    }
    
    private func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Padding.spacingXXS) {
                Text(title)
                    .custom(
                        size: 16,
                        color: isSelected ? Color(.primary) : Color(.textPrimary),
                        weight: isSelected ? .bold : .regular
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Padding.spacingXM)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
