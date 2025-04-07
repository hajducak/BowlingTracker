
import SwiftUI

struct PinCoverageView: View {
    @ObservedObject var viewModel: PinCoverageViewModel
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            let graphSize = (UIScreen.main.bounds.size.width / 3.2) - Padding.defaultPadding * 1.2
            Text(title)
                .title()
                .padding(.horizontal, Padding.defaultPadding)
            TooltipView(info: "Select any combination of pins to calculate how frequently they were coverd.")
                .padding(.bottom, Padding.spacingXS)
            HStack(alignment: .center, spacing: Padding.spacingS) {
                Spacer()
                CircularProgressView(
                    percentage: viewModel.coveragePercentage,
                    title: "Coverage",
                    description: viewModel.coverageCount,
                    size: .init(width: graphSize, height: graphSize),
                    percentageModifier: 0.23,
                    titleModifier: 0.14
                )
                Spacer()
                PinsGrid(
                    pinSize: .init(width: 30, height: 30),
                    contentSpacing: Padding.spacingS,
                    selectedPins: $viewModel.selectedPinIds,
                    disabledPins: viewModel.disabledPinIds
                )
            }.padding(.horizontal, Padding.defaultPadding)
        }
    }
}
