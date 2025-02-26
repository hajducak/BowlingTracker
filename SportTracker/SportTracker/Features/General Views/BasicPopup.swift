import SwiftUI

struct BasicPopup<Content: View>: View {
    @Binding var isVisible: Bool
    var title: String
    var content: () -> Content
    var onDismiss: (() -> Void)?
    var onConfirm: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(isVisible ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isVisible = false
                        onDismiss?()
                    }
                }

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle).bold()
                    .padding(.horizontal, 20)
                content()
                HStack {
                    Button("Close") {
                        withAnimation(.easeInOut) {
                            isVisible = false
                            onDismiss?()
                        }
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    Spacer()
                    onConfirm.map { _ in
                        Button("Save") {
                            onConfirm?()
                            withAnimation(.easeInOut) {
                                isVisible = false
                            }
                        }
                        .foregroundColor(.blue)
                        .bold()
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            .offset(y: isVisible ? 0 : UIScreen.main.bounds.height)
            .animation(.spring(), value: isVisible)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .hideTabBar(when: $isVisible)
    }
}

#Preview {
    BasicPopup(isVisible: .constant(true), title: "Popup title") {
        Text("Popup Content").padding(.horizontal, 20)
    } onDismiss: {
        
    } onConfirm: {
        
    }

}
