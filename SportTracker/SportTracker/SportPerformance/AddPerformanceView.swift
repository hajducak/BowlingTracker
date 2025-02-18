import SwiftUI
import SwiftData

struct AddPerformanceView: View {
    @ObservedObject var viewModel: AddPerformanceViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Picker("Storage Type", selection: $viewModel.storageType) {
                    Text("Local 🟢")
                        .tag(StorageType.local)
                        .accessibilityIdentifier("localButton")
                    Text("Remote 🔵")
                        .tag(StorageType.remote)
                        .accessibilityIdentifier("remoteButton")
                }
                .accessibilityIdentifier("storageType")
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 15)
                .labled(label: "Choose database type:")
                TextField("Enter name", text: $viewModel.name)
                    .textFieldStyle(labeled: "Performance Name:")
                TextField("Enter location", text: $viewModel.location)
                    .textFieldStyle(labeled: "Performance Location:")
                TextField("Enter duration", text: $viewModel.duration)
                    .textFieldStyle(labeled: "Performance Duration:")
                    .keyboardType(.numberPad)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            Button(action: {
                viewModel.savePerformance()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(viewModel.isLoading ? "Saving..." : "Save Performance")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .disabled(viewModel.isLoading)
            }
            .disabled(viewModel.isDisabled)
            .opacity(viewModel.isDisabled ? 0.5 : 1)
        }
        .navigationBarTitle("Add Performance")
        .toast($viewModel.toast, timeout: 3)
    }
}

#Preview {
    let storageManager = try! StorageManager(modelContainer: try! ModelContainer(for: SportPerformance.self))
    let firebaseManager = FirebaseManager.shared
    let addPerformanceViewModel = AddPerformanceViewModel(storageManager: storageManager, firebaseManager: firebaseManager)
    AddPerformanceView(viewModel: addPerformanceViewModel)
}

struct CustomTextFieldStyle: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 50)
            .background(Color.gray.opacity(0.2).cornerRadius(8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .labled(label: label)
    }
}

struct LabeledStyle: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).bold()
            content.padding(.bottom, 15)
        }
    }
}

extension View {
    func textFieldStyle(labeled: String) -> some View {
        modifier(CustomTextFieldStyle(label: labeled))
    }
    
    func labled(label: String) -> some View {
        modifier(LabeledStyle(label: label))
    }
}
