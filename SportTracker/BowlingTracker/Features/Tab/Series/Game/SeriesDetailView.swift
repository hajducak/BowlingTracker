import SwiftUI

struct SeriesDetailView: View {
    @ObservedObject var viewModel: SeriesDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State var showEditSeries: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Padding.spacingS) {
                switch viewModel.state {
                case .playing(let game):
                    ScrollView {
                        VStack(alignment: .leading, spacing: Padding.spacingXXS) {
                            Text(viewModel.series.description)
                                .body()
                                .padding(.horizontal, Padding.defaultPadding)
                            oilPatternLink
                            Text("Current game")
                                .title()
                                .padding(.horizontal, Padding.defaultPadding)
                                .padding(.top, Padding.spacingM)
                            GameView(viewModel: game)
                            PreviousGamesView(viewModel: viewModel)
                                .padding(.top, Padding.spacingM)
                        }.padding(.bottom, Padding.defaultPadding)
                    }
                    .navigationBarItems(
                        trailing:
                            Button(action: {
                                viewModel.saveSeries()
                            }, label: {
                                HStack {
                                    Text("Save")
                                        .heading(color: Color(.primary))
                                    Image(systemName: "folder.circle")
                                        .foregroundColor(Color(.primary))
                                }
                            })
                    )
                    .onReceive(viewModel.$shouldDismiss) { if $0 { dismiss() }}
                    .loadingOverlay(when: $viewModel.isLoadingOverlay, title: "Saving game...")
                case .empty: empty
                case .content: content
                }
            }
            .navigationTitle(viewModel.series.name)
            .toast($viewModel.toast, timeout: 3)
            .navigationBarItems(
                leading:
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.backward.circle")
                                .foregroundColor(Color(.primary))
                            Text("Back")
                                .heading(color: Color(.primary))
                        }
                    })
            ).background(Color(.bgPrimary))
        }
        .accentColor(Color(.primary))
        .navigationBarBackButtonHidden()
        .fullScreenCover(item: $viewModel.selectedBall) { ballViewModel in
            BallDetailView(viewModel: ballViewModel)
        }
    }
    
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: Padding.spacingS) {
                VStack(alignment: .leading, spacing: Padding.spacingXXS) {
                    viewModel.series.house.map {
                        Text($0)
                            .heading()
                            .padding(.horizontal, Padding.defaultPadding)
                    }
                    Text(viewModel.series.formattedDate)
                        .body()
                        .padding(.horizontal, Padding.defaultPadding)
                    Text(viewModel.series.description)
                        .body()
                        .padding(.horizontal, Padding.defaultPadding)
                    oilPatternLink
                }
                if let statistics = viewModel.basicStatisticsViewModel {
                    BasicStatisticsView(viewModel: statistics, title: "Statistics")
                }
                Text("Games played")
                    .title()
                    .padding(.horizontal, Padding.defaultPadding)
                    .padding(.top, Padding.spacingXXS)
                GamesListView(viewModel: viewModel)

                Text("Used balls")
                    .title()
                    .padding(.horizontal, Padding.defaultPadding)
                    .padding(.top, Padding.spacingXXS)
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: Padding.spacingM) {
                        ForEach(viewModel.seriesUsedBalls) { ball in
                            ImageBallView(ball: ball, onTap: { viewModel.openDetail($0) })
                        }
                    }.padding(.horizontal, Padding.defaultPadding)
                }
                if let advancedStatisticsViewModel = viewModel.advancedStatisticsViewModel {
                    AdvancedStatisticsView(viewModel: advancedStatisticsViewModel, title: "Advanced")
                }
                if let pinCoverageViewModel = viewModel.pinCoverageViewModel {
                    PinCoverageView(viewModel: pinCoverageViewModel, title: "Pin coverage")
                }
            }
            Spacer().frame(height: Padding.defaultPadding)
        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        showEditSeries.toggle()
                    }
                }, label: {
                    HStack {
                        Text("Edit")
                            .heading(color: Color(.primary))
                        Image(systemName: "pencil.circle")
                            .foregroundColor(Color(.primary))
                    }
                })
        )
        .fullScreenCover(isPresented: $showEditSeries) {
            CreateSeriesView(
                title: "Edit series",
                seriesName: $viewModel.newSeriesName,
                seriesDescription: $viewModel.newSeriesDescription,
                seriesOilPatternName: $viewModel.newSeriesOilPatternName,
                seriesOilPatternURL: $viewModel.newSeriesOilPatternURL,
                seriesHouse: $viewModel.newSeriesHouseName,
                selectedType: $viewModel.newSeriesSelectedType,
                selectedDate: $viewModel.newSeriesSelectedDate,
                onSave: {
                    viewModel.updateSeries()
                    showEditSeries.toggle()
                },
                onClose: {
                    showEditSeries.toggle()
                }
            )
        }.loadingOverlay(when: $viewModel.isLoadingOverlay, title: "Editing series...")
    }
    
    private var empty: some View {
        VStack(spacing: Padding.spacingL) {
            Spacer()
            Text("No games found")
                .title(color: Color(.textSecondary))
            Spacer()
        }.padding(.horizontal, Padding.defaultPadding)
    }
    
    private var oilPatternLink: some View {
        Group {
            if let oilPatternName = viewModel.series.oilPatternName, !oilPatternName.isEmpty {
                if let oilPatternURL = viewModel.series.oilPatternURL, !oilPatternURL.isEmpty, let url = URL(string: oilPatternURL) {
                    Link(destination: url) {
                        HStack(alignment: .top) {
                            Image(systemName: "link.circle")
                            Text(oilPatternName)
                                .multilineTextAlignment(.leading)
                                .body(color: Color(.primary))
                                .underline()
                        }
                    }.padding(.horizontal, Padding.defaultPadding)
                } else {
                    Text("Oil pattern: \(oilPatternName)")
                        .multilineTextAlignment(.leading)
                        .body()
                        .padding(.horizontal, Padding.defaultPadding)
                }
            }
        }
    }
}
