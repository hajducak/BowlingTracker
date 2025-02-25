import SwiftUI

struct ToastView: View {
    let toast: Toast

    var body: some View {
        Text(toast.toastMessage)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom, 70)
    }
}


extension View {
    func toast(_ toast: Binding<Toast?>, timeout: TimeInterval) -> some View {
        modifier(ToastModifier(toast: toast, timeout: timeout))
    }
}


struct ToastModifier: ViewModifier {
    let timeout: TimeInterval
    @Binding var toast: Toast?

    init(toast: Binding<Toast?>, timeout: TimeInterval = 3) {
        _toast = toast
        self.timeout = timeout
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                if let toast {
                    ToastView(toast: toast)
                        .animation(.easeInOut(duration: 0.5))
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
                                self.toast = nil
                            }
                        }
                }
            }
        }
    }
}
