import SwiftUI

struct AddPerformanceView: View {
    @ObservedObject var viewModel: SportPerformanceViewModel
    
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var duration: String = ""
    @State private var selectedStorage: StorageType = .local
    
    var body: some View {
        VStack {
            TextField("Enter performance name", text: $name)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance location", text: $location)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter performance duration (in minutes)", text: $duration)
                .padding().textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Picker("Storage Type", selection: $selectedStorage) {
                Text("Local").tag(StorageType.local)
                Text("Remote").tag(StorageType.remote)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Save Performance") {
                if let duration = Int(duration) {
                    viewModel.addPerformance(name: name, location: location, duration: duration, storageType: selectedStorage)
                }
            }
            .padding().background(Color.blue).foregroundColor(.white).cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Add Performance")
    }
}
