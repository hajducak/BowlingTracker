import SwiftUI

struct SeriesView: View {
    @ObservedObject var viewModel: SeriesViewModel
    @State private var showCreateSeries = false

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
                .navigationBarItems(trailing: addButton)
                .fullScreenCover(isPresented: $showCreateSeries) {
                    CreateSeriesView(
                        seriesName: $viewModel.newSeriesName,
                        seriesDescription: $viewModel.newSeriesDescription,
                        selectedType: $viewModel.newSeriesSelectedType,
                        selectedDate: $viewModel.newSeriesSelectedDate,
                        onSave: {
                            viewModel.addSeries()
                            showCreateSeries = false
                        },
                        onClose: {
                            showCreateSeries = false
                        }
                    )
                }
        }
    }

    private var addButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showCreateSeries = true
            }
        }) {
            Label("Add", systemImage: "plus.circle.fill")
                .foregroundColor(.orange)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading series...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty, .content:
                FilterView(selectedFilter: $viewModel.selectedFilter)
                    .padding(.bottom, Padding.spacingS)
                switch viewModel.state {
                case .empty:
                    VStack {
                        Spacer()
                        Text("No series found")
                            .title()
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                case .content(let series):
                    ScrollView {
                        Spacer().frame(height: Padding.spacingXXXS)
                        ForEach(series, id: \.id) { item in
                            NavigationLink(destination: SeriesDetailView(
                                viewModel: item
                            )) {
                                SeriesCell(series: item.series) { viewModel.deleteSeries($0) }
                                    .padding(.bottom, Padding.spacingS)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        Spacer().frame(height: Padding.spacingM)
                    }
                case .loading: EmptyView()
                }
            }
        }
    }
}
