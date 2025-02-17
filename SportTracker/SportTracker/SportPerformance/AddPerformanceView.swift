import SwiftUI

struct AddPerformanceView: View {
    @ObservedObject var viewModel: AddPerformanceViewModel
    
    var body: some View {
        VStack {
            TextField("Enter performance name", text: $viewModel.name)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance location", text: $viewModel.location)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance duration (in minutes)", text: $viewModel.duration)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Picker("Storage Type", selection: $viewModel.storageType) {
                Text("Local").tag(StorageType.local)
                Text("Remote").tag(StorageType.remote)
            }
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

            Spacer()
        }
        .padding()
        .navigationBarTitle("Add Performance")
        .overlay(
            ToastView(message: viewModel.toastMessage, isShowing: $viewModel.showToast)
        )
    }
}


