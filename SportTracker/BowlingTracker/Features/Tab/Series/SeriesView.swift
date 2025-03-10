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
        switch viewModel.state {
        case .loading:
            ProgressView("Loading series...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            VStack {
                FilterView(selectedFilter: $viewModel.selectedFilter)
                    .padding(.bottom, Padding.spacingS)
                Spacer()
                Text("No series found")
                    .title()
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
        case .content(let series):
            FilterView(selectedFilter: $viewModel.selectedFilter)
                .padding(.bottom, Padding.spacingS)
            ScrollView {
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
        }
    }
}
