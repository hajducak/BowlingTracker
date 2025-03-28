import SwiftUI

struct CustomCornerRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: topLeft, y: 0))
        path.addLine(to: CGPoint(x: rect.width - topRight, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: topRight),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - bottomRight, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: bottomLeft, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height - bottomLeft),
            control: CGPoint(x: 0, y: rect.height)
        )
        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addQuadCurve(
            to: CGPoint(x: topLeft, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        return path
    }
}

extension View {
    func customCornerRadius(
        topLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) -> some View {
        clipShape(CustomCornerRectangle(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        ))
    }
}
