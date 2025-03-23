import SwiftUI
import Charts

struct SeriesAverageView: View {
    @ObservedObject var viewModel: SeriesAverageViewModel
    
    let linearGradient = LinearGradient(
        gradient: Gradient(
            colors: [Color(.primary).opacity(0.4), Color(.primary).opacity(0)]),
            startPoint: .top,
            endPoint: .bottom
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            Text("Series Averages")
                .title()
                .padding(.horizontal, Padding.defaultPadding)
            
            Chart {
                ForEach(Array(viewModel.averages.enumerated()), id: \.offset) { index, average in
                    LineMark(
                        x: .value("Series", index + 1),
                        y: .value("Average", average)
                    )
                    .foregroundStyle(Color(.primary))
                    .interpolationMethod(.cardinal)
                    AreaMark(
                        x: .value("Series", index + 1),
                        y: .value("Average", average)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(linearGradient)
                    PointMark(
                        x: .value("Series", index + 1),
                        y: .value("Average", average)
                    )
                    .foregroundStyle(Color(.primary))
                    .annotation(position: .automatic) {
                        Text(average.twoPointFormat())
                            .custom(size: 8, color: .textPrimaryInverse, weight: .bold)
                            .padding(.horizontal, Padding.spacingXXXS)
                            .padding(.vertical, Padding.spacingXXXS)
                            .background(Color(.primary))
                            .cornerRadius(Corners.corenrRadiusS)
                    }
                }
                RuleMark(y: .value("Average", viewModel.totalAverage))
                    .foregroundStyle(Color(.complementary))
                    .annotation(
                        position: .top,
                        alignment: .topTrailing
                    ) {
                        Text("Average \(viewModel.totalAverage.twoPointFormat())")
                            .custom(size: 8, color: .textPrimaryInverse, weight: .bold)
                            .padding(.horizontal, Padding.spacingXXS)
                            .padding(.vertical, Padding.spacingXXS)
                            .background(Color(.complementary))
                            .cornerRadius(Corners.corenrRadiusS, corners: [.topLeft, .topRight])
                            .offset(x: -10, y: 4)
                    }
            }
            .chartYScale(domain: viewModel.minAverage...viewModel.maxAverage)
            .chartXScale(domain: 1...viewModel.averages.count)
            .chartLegend(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let average = value.as(Double.self) {
                        AxisGridLine()
                        AxisValueLabel {
                            Text(String(format: "%.0f", average))
                                .caption()
                                .foregroundColor(Color(.textSecondary))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    if let index = value.as(Int.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(index)")
                                .caption()
                                .foregroundColor(Color(.textSecondary))
                        }
                    }
                }
            }
            .frame(height: 250)
            .padding(.horizontal, Padding.spacingXL)
            .padding(.top, Padding.spacingL)
            .clipped()
        }
    }
}
