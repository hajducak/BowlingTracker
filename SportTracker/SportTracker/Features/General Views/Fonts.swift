import SwiftUI

extension View {
    /// 24px, .bold, .primary
    func title(color: Color = .primary) -> some View {
        self.modifier(TitleModifier(color: color))
    }
    
    /// 16px, .bold, .primary
    func heading(color: Color = .primary) -> some View {
        self.modifier(HeadingModifier(color: color))
    }

    /// 14px, .bold, .primary
    func subheading(color: Color = .primary, weight: Font.Weight? = .bold) -> some View {
        self.modifier(SubheadingModifier(color: color, weight: weight))
    }
    
    /// 12px, .regular, .systemGrey2
    func caption(color: Color = UIColor.systemGray2.color) -> some View {
        self.modifier(CaptionModifier(color: color))
    }
}

/// size: 24, .bold
struct TitleModifier: ViewModifier {
    var color: Color = .primary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
    }
}

/// size: 16, .bold
struct HeadingModifier: ViewModifier {
    var color: Color = .primary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(color)
    }
}

/// size: 14, default .bold
struct SubheadingModifier: ViewModifier {
    var color: Color = .primary
    var weight: Font.Weight? = .bold

    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: weight))
            .foregroundColor(color)
    }
}

/// size: 12, .regular, .systemGray4
struct CaptionModifier: ViewModifier {
    var color: Color = UIColor.systemGray2.color

    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(color)
    }
}
