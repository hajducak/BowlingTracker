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

            VStack(alignment: .leading, spacing: Padding.defaultPadding) {
                Text(title)
                    .title()
                    .padding(.horizontal, Padding.defaultPadding)
                content()
                HStack {
                    Button {
                        withAnimation(.easeInOut) {
                            isVisible = false
                            onDismiss?()
                        }
                    } label: {
                        Text("Close")
                            .heading()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(.orange)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: Corners.corenrRadiusM)
                            .stroke(Color.orange, lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                    Spacer()
                    onConfirm.map { _ in
                        Button {
                            onConfirm?()
                            withAnimation(.easeInOut) {
                                isVisible = false
                            }
                        } label: {
                            Text("Save")
                                .heading()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(Corners.corenrRadiusM)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .padding(.vertical, Padding.defaultPadding)
            .background(Color.white)
            .cornerRadius(Corners.corenrRadiusL, corners: [.topLeft, .topRight])
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
        Text("Popup Content").padding(.horizontal, Padding.defaultPadding)
    } onDismiss: {
        
    } onConfirm: {
        
    }

}
