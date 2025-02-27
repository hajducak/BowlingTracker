import SwiftUI

struct SeriesView: View {
    @ObservedObject var viewModel: SeriesViewModel
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
                Spacer()
                Text("No series found")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
        case .content(let series):
            ScrollView {
                ForEach(series, id: \.id) { item in
                    NavigationLink(destination: SeriesDetailView(
                        viewModel: item
                    )) {
                        SeriesCell(series: item.series) { viewModel.deleteSeries($0) }
                            .padding(.bottom, 8)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
