import SwiftUI

struct EditProfileView: View {
    @Binding var name: String
    @Binding var homeCenter: String
    @Binding var style: BowlingStyle
    @Binding var hand: HandStyle
    var onSave: (() -> Void)?
    var onClose: () -> Void

    var body : some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: Padding.spacingXXM) {
                TextField("Enter your name", text: $name)
                    .defaultTextFieldStyle(labeled: "Profile Name")
                TextField("Enter name of your home center", text: $homeCenter)
                    .defaultTextFieldStyle(labeled: "Home Center")
                
                Picker("Select type", selection: $style) {
                    Text("Two handed").tag(BowlingStyle.twoHanded)
                    Text("One handed").tag(BowlingStyle.oneHanded)
                }
                .pickerStyle(SegmentedPickerStyle())
                .heading()
                .labled(label: "Your Bowling Style")
                
                Picker("Select hand", selection: $hand) {
                    Text("Lefty").tag(HandStyle.lefty)
                    Text("Righty").tag(HandStyle.righty)
                }
                .pickerStyle(SegmentedPickerStyle())
                .heading()
                .labled(label: "Your Bowling Hand")
            }.padding(.horizontal, Padding.defaultPadding)
            Spacer()
            buttons
                .padding(.vertical, Padding.defaultPadding)
                .padding(.bottom, Padding.defaultPadding)
                .background {
                    RoundedRectangle(cornerRadius: Corners.corenrRadiusL)
                        .fill(Color(.bgSecondary))
                }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    private var buttons: some View {
        HStack {
            SecondaryButton(
                title: "Close",
                isLoading: false,
                isEnabled: true,
                backgroundColor: Color(.bgSecondary),
                action: onClose
            )
            Spacer()
            onSave.map { _ in
                PrimaryButton(
                    title: "Save",
                    isLoading: false,
                    isEnabled: true,
                    action: { onSave?() }
                )
            }
        }
        .padding(.horizontal, Padding.defaultPadding)
    }
}
