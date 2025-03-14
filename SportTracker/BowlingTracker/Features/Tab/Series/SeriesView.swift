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
                        seriesOilPatternName: $viewModel.newSeriesOilPatternName,
                        seriesOilPatternURL: $viewModel.newSeriesOilPatternURL,
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
            Label("Add", systemImage: "plus.circle")
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
                    VStack(spacing: Padding.spacingL) {
                        Spacer()
                        Text("No series found")
                            .title(color: DefaultColor.grey3)
                        Text("Create a new bowling series by clicking the '+' icon in the top-right corner. Once you do, you can add the name, description, oil pattern, and other details for your new series. It’s that easy to get started!")
                            .subheading(color: DefaultColor.grey3, weight: .regular).multilineTextAlignment(.center)
                        Spacer()
                    }.padding(.horizontal, Padding.defaultPadding)
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
