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
