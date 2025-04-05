import SwiftUI

struct EmptyBallView: View {
    @State private var isBallPulsing = false
    var size: CGSize = .init(width: 80, height: 80)
    let onTap: () -> ()
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.bgTerciary))
                .frame(width: size.width, height: size.height)
            Circle()
                .fill(Color(.bgPrimary))
                .frame(width: size.width - 5, height: size.height - 5)
            Circle()
                .fill(Color(.bgTerciary))
                .frame(width: size.width - 18, height: size.height - 18)
                .scaleEffect(isBallPulsing ? 1.0 : 0.9)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                    ) {
                        isBallPulsing.toggle()
                    }
                }
            Image(systemName: "plus")
                .foregroundColor(Color(.primary))
                .title()
        }.tap { onTap() }
    }
}
