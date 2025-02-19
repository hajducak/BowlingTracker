import SwiftUI

struct BowlingSeriesView: View {
    @ObservedObject var viewModel: BowlingSeriesViewModel
    @State private var showAlert = false
    @State private var seriesName = ""

    var body: some View {
        contentView
            .navigationBarItems(trailing: addButton)
            .alert("Enter Series Name", isPresented: $showAlert) {
                TextField("Series Name", text: $seriesName)
                
                Button("Cancel", role: .cancel) {
                    seriesName = ""
                }
                
                Button("OK") {
                    viewModel.addSeries(name: seriesName)
                    seriesName = ""
                }
                .disabled(seriesName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
    }

    private var addButton: some View {
        Button(action: {
            showAlert = true
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
                    SeriesCell(series: item) { viewModel.deleteSeries($0) }
                }
                Spacer()
            }
        }
    }
}

struct SeriesCell: View {
    var series: Series
    var onDeleteSeries: (Series) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(series.tag.rawValue)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.blue.cornerRadius(8))
            Text(series.name)
                .padding(.bottom, 6)
            Text(series.formattedDate)
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.bottom, 6)
        }
        .flexWidthModifier(alignment: .leading)
        .padding(.horizontal, 20)
        .tap(count: 3) {
            onDeleteSeries(series)
        }
    }
}

extension View {
    @ViewBuilder
    func tap(count: Int, perform: @escaping () -> Void) -> some View {
        contentShape(Rectangle())
            .onTapGesture(count: count, perform: perform)
    }
    
    func flexWidthModifier(alignment: Alignment = .center) -> some View {
        modifier(FlexWidthModifier(alignment: alignment))
    }
}

struct FlexWidthModifier: ViewModifier {
    let alignment: Alignment
    init(alignment: Alignment = .center) {
        self.alignment = alignment
    }
    func body(content: Content) -> some View {
        content.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
}
