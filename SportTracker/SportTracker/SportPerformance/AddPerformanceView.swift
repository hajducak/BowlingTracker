import SwiftUI

struct AddPerformanceView: View {
    @ObservedObject var viewModel: AddPerformanceViewModel
    
    var body: some View {
        ScrollView {
            TextField("Enter performance name", text: $viewModel.name)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance location", text: $viewModel.location)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance duration (in minutes)", text: $viewModel.duration)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Picker("Storage Type", selection: $viewModel.storageType) {
                Text("Local").tag(StorageType.local)
                    .accessibilityIdentifier("localButton")
                Text("Remote").tag(StorageType.remote)
                    .accessibilityIdentifier("remoteButton")
            }.accessibilityIdentifier("storageType")
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
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
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
            }
            .padding()
            .disabled(viewModel.isDisabled)
            .opacity(viewModel.isDisabled ? 0.5 : 1)

            Spacer()
        }
        .padding()
        .navigationBarTitle("Add Performance")
        .toast($viewModel.toast, timeout: 3)
    }
}
