import SwiftUI

struct PerformanceListView: View {
    @ObservedObject var viewModel: PerformanceListViewModel
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
            if viewModel.isLoading {
                ProgressView("Loading performances...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
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
            if let toastMessage = viewModel.toastMessage, viewModel.showToast {
                Text(toastMessage)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .transition(.move(edge: .top))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.showToast = false
                            }
                        }
                    }
            }
        }
        .navigationBarTitle("Performance List")
        .task {
            viewModel.fetchPerformances(filter: selectedFilter)
        }
        .onChange(of: selectedFilter, { _, newValue in
            Task {
                viewModel.fetchPerformances(filter: newValue)
            }
        })
    }
}
