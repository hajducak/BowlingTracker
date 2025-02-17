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
            
            Button("Save Performance") {
                viewModel.savePerformance()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Add Performance")
    }
}
