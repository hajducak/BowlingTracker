
import SwiftUI

struct PinCoverageView: View {
    @ObservedObject var viewModel: PinCoverageViewModel
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            let graphSize = (UIScreen.main.bounds.size.width / 3.5) - Padding.defaultPadding*1.2
            Text(title)
                .title()
                .padding(.horizontal, Padding.defaultPadding)

            HStack(alignment: .center, spacing: Padding.spacingS) {
                PinsGrid(
                    pinSize: .init(width: 30, height: 30),
                    contentSpacing: Padding.spacingS,
                    selectedPins: $viewModel.selectedPinIds,
                    disabledPins: viewModel.disabledPinIds
                )
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: Corners.corenrRadiusXL)
                        .stroke(Color(.primary), lineWidth: 2)
                )
                VStack(alignment: .center, spacing: Padding.spacingXM) {
                    CircularProgressView(
                        percentage: viewModel.coveragePercentage,
                        title: "Coverage",
                        description: viewModel.coverageCount,
                        size: .init(width: graphSize, height: graphSize)
                    )
                    Spacer()
                    SecondaryButton(title: "Calculate", isLoading: false, isEnabled: viewModel.calculateIsEnabled) {
                        viewModel.calculateCoverage()
                    }.padding(.horizontal, Padding.defaultPadding)
                }
            }.padding(.horizontal, Padding.defaultPadding)

        }
    }
}
