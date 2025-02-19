import SwiftUI

struct BowlingSeriesView: View {
    @ObservedObject var viewModel: BowlingSeriesViewModel
    
    var body: some View {
        contentView
            .navigationBarItems(trailing: addButton)
        
    }
    
    private var addButton: some View {
        Button(action: {
            viewModel.addSeries()
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
            List(series) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(item.tag.rawValue)
                        .foregroundColor(.gray)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}
