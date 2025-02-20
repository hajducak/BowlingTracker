import SwiftUI

struct BowlingSeriesView: View {
    @ObservedObject var viewModel: BowlingSeriesViewModel
    @State private var showPopup = false
    @State private var seriesName = ""
    @State private var selectedType: SeriesType = .league
    @State private var selectedDate = Date()

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
                .navigationBarItems(trailing: addButton)
            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .tap {
                        showPopup = false
                    }
                SeriesPopupView(
                    isVisible: $showPopup,
                    seriesName: $seriesName,
                    selectedType: $selectedType,
                    selectedDate: $selectedDate
                ) {
                    viewModel.addSeries(name: seriesName, type: selectedType, date: selectedDate)
                }
            }
        }
    }

    private var addButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showPopup = true
            }
        }) {
            Label("Add", systemImage: "plus.circle.fill")
                .foregroundColor(.black)
        }
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
            VStack {
                Spacer()
                Text("No series found")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
        case .content(let series):
            ScrollView {
                ForEach(series) { item in
                    NavigationLink(destination: SeriesDetailView(
                        viewModel: SeriesDetailViewModel(
                            firebaseManager: viewModel.firebaseManager,
                            series: item
                        )
                    )) {
                        SeriesCell(series: item) { viewModel.deleteSeries($0) }
                    }.buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
        }
    }
}
