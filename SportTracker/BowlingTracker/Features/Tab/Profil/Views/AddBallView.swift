import SwiftUI

struct AddBallView: View {
    let title: String

    @Binding var name: String
    @Binding var brand: String
    @Binding var imageURL: String
    
    @Binding var weight: String
    @Binding var rg: String
    @Binding var diff: String
    
    @Binding var pinToPap: String
    @Binding var layout: String
    
    @Binding var coreImageUrl: String
    @Binding var core: String
    @Binding var surface: String
    @Binding var coverstock: String
    @Binding var lenght: String
    @Binding var backend: String
    @Binding var hook: String

    var onSave: (() -> Void)?
    var onClose: () -> Void

    var body : some View {
        VStack(alignment: .leading) {
            Text(title)
                .title()
                .padding(.horizontal, Padding.defaultPadding)
            ScrollView {
                VStack(alignment: .leading, spacing: Padding.spacingXXM) {
                    TextField("Enter ball name", text: $name)
                        .defaultTextFieldStyle(labeled: "*Ball name")
                    
                    TextField("Enter ball brand name", text: $brand)
                        .defaultTextFieldStyle(labeled: "Brand")
                    
                    TextField("Enter image url", text: $imageURL)
                        .defaultTextFieldStyle(labeled: "Ball picture")
                    
                    TextField("Enter ball weight", text: $weight)
                        .keyboardType(.numberPad)
                        .defaultTextFieldStyle(labeled: "*Weight")
                    
                    TextField("Enter ball RG", text: $rg)
                        .keyboardType(.decimalPad)
                        .defaultTextFieldStyle(labeled: "Radius of Gyration")
                    
                    TextField("Enter ball Diff", text: $diff)
                        .keyboardType(.decimalPad)
                        .defaultTextFieldStyle(labeled: "Differential")
                    
                    TextField("Enter ball PIN-TO-PAP", text: $pinToPap)
                        .keyboardType(.decimalPad)
                        .defaultTextFieldStyle(labeled: "PIN-to-PAP Distance")
                    
                    TextField("Enter ball layout", text: $layout)
                        .defaultTextFieldStyle(labeled: "Ball layout")
                    
                    TextField("Enter core image", text: $coreImageUrl)
                        .defaultTextFieldStyle(labeled: "Core image")
                    
                    TextField("Enter ball core", text: $core)
                        .defaultTextFieldStyle(labeled: "Core")
                    
                    TextField("Enter ball coverstock", text: $coverstock)
                        .defaultTextFieldStyle(labeled: "Coverstock")
                    
                    TextField("Enter ball surface", text: $surface)
                        .defaultTextFieldStyle(labeled: "Surface")
                    
                    TextField("Enter ball lenght", text: $lenght)
                        .defaultTextFieldStyle(labeled: "Lenght")
                    
                        .keyboardType(.numberPad)
                    TextField("Enter ball backend", text: $backend)
                        .defaultTextFieldStyle(labeled: "Backend")
                    
                        .keyboardType(.numberPad)
                    TextField("Enter ball hook", text: $hook)
                        .defaultTextFieldStyle(labeled: "Hook")
                    
                        .keyboardType(.numberPad)
                }.padding(.horizontal, Padding.defaultPadding)
            }
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
                    isEnabled: !name.isEmpty && !weight.isEmpty,
                    action: { onSave?() }
                )
            }
        }
        .padding(.horizontal, Padding.defaultPadding)
    }
}
