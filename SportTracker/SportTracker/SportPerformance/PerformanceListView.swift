import SwiftUI

struct PerformanceListView: View {
    @ObservedObject var viewModel: SportPerformanceViewModel
    
    @State private var selectedFilter: StorageType? = nil
    
    var body: some View {
        VStack {
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(StorageType?.none)
                Text("Local").tag(StorageType.local)
                Text("Remote").tag(StorageType.remote)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List(viewModel.performances) { performance in
                HStack {
                    Text(performance.name)
                    Spacer()
                    Text("\(performance.duration) min")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(performance.storageType == StorageType.local.rawValue ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                .cornerRadius(8)
            }
            .onAppear {
                viewModel.fetchPerformances(filter: selectedFilter)
            }
        }
        .navigationBarTitle("Performance List")
    }
}
