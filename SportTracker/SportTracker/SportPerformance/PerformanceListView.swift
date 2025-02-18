import SwiftUI

struct PerformanceListView: View {
    @ObservedObject var viewModel: PerformanceListViewModel
    @State private var selectedFilter: StorageType? = nil
    @State private var showDeleteConfirmation = false
    @EnvironmentObject var tabSelectionViewModel: TabSelectionViewModel

    var body: some View {
        VStack {
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(StorageType?.none)
                Text("Local").tag(StorageType.local)
                Text("Remote").tag(StorageType.remote)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            contentView
        }
        .navigationBarTitle("Performance List")
        .navigationBarItems(trailing: deleteAllButton)
        .task {
            viewModel.fetchPerformances(filter: selectedFilter)
        }
        .onChange(of: selectedFilter, { _, newValue in
            Task {
                viewModel.fetchPerformances(filter: newValue)
            }
        })
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete all performances? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete All")) {
                    viewModel.deleteAllPerformances()
                },
                secondaryButton: .cancel()
            )
        }
        .toast($viewModel.toast, timeout: 3)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading performances...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            emptyView
        case .content(let performances):
            List(performances) { performance in
                HStack {
                    Text(performance.name)
                    Spacer()
                    Text("\(performance.duration) min")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(performance.storageType == StorageType.local.rawValue ? Color.green.opacity(0.3) : Color.blue.opacity(0.3))
                .cornerRadius(8)
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deletePerformance(performance)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var deleteAllButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            Label("Delete All", systemImage: "trash.fill")
                .foregroundColor(.red)
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No performances found")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
            
            Button(action: {
                tabSelectionViewModel.selectAddTab()
            }) {
                Text("Add a Performance")
                    .foregroundColor(.blue)
            }
            .padding()
            Spacer()
        }
    }
}
