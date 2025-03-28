import SwiftUI

extension View {
    /// 24px, .bold, .primary
    func title(color: Color = .textPrimary) -> some View {
        self.modifier(TitleModifier(color: color))
    }
    
    /// 16px, .bold, .primary
    func heading(color: Color = .textPrimary) -> some View {
        self.modifier(HeadingModifier(color: color))
    }
    
    /// 16px, .regular, .primary
    func body(color: Color = .textPrimary) -> some View {
        self.modifier(BodyModifier(color: color))
    }

    /// 14px, .bold, .primary
    func subheading(color: Color = .textPrimary, weight: Font.Weight? = .bold) -> some View {
        self.modifier(SubheadingModifier(color: color, weight: weight))
    }
    
    /// 12px, .regular, .systemGrey2
    func caption(color: Color = .textSecondary, weight: Font.Weight? = .regular) -> some View {
        self.modifier(CaptionModifier(color: color, weight: weight))
    }

    /// 10px, .bold, .white
    func smallNegative(color: Color = .textPrimaryInverse) -> some View {
        self.modifier(SmallNegativeModifier(color: color))
    }
    
    /// default size: 12, .regular, .primary
    /// You can set all parameters based on needs
    func custom(size: CGFloat, color: Color = .textPrimary, weight: Font.Weight? = .regular) -> some View {
        self.modifier(CustomTextModifier(size: size, color: color, weight: weight))
    }
}

/// size: 24, .bold
struct TitleModifier: ViewModifier {
    var color: Color = .textPrimary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
    }
}

/// size: 16, .bold
struct HeadingModifier: ViewModifier {
    var color: Color = .textPrimary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(color)
    }
}

/// size: 16, .bold
struct BodyModifier: ViewModifier {
    var color: Color = .textPrimary

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(color)
    }
}

/// size: 14, default .bold
struct SubheadingModifier: ViewModifier {
    var color: Color = .textPrimary
    var weight: Font.Weight? = .bold

    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: weight))
            .foregroundColor(color)
    }
}

/// size: 12, .regular, .systemGray4
struct CaptionModifier: ViewModifier {
    var color: Color = .textSecondary
    var weight: Font.Weight? = .regular

    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: weight))
            .foregroundColor(color)
    }
}

/// size: 10, .bold, .white
struct SmallNegativeModifier: ViewModifier {
    var color: Color = .textPrimaryInverse

    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
    }
}

/// default size: 12, .regular, .primary
/// you can set all parameters based on needs
struct CustomTextModifier: ViewModifier {
    var size: CGFloat = 12
    var color: Color = .textPrimary
    var weight: Font.Weight? = .regular

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}
