
import SwiftUI

struct PinCoverageView: View {
    @ObservedObject var viewModel: PinCoverageViewModel
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.spacingS) {
            let graphSize = (UIScreen.main.bounds.size.width / 4) - Padding.defaultPadding*1.2
            Text(title)
                .title()
                .padding(.horizontal, Padding.defaultPadding)

            PinsGrid(
                selectedPins: $viewModel.selectedPinIds,
                disabledPins: viewModel.disabledPinIds
            )

            PrimaryButton(title: "Calculate", isLoading: false, isEnabled: viewModel.calculateIsEnabled) {
                viewModel.calculateCoverage()
            }
            
            CircularProgressView(
                percentage: viewModel.coveragePercentage,
                title: "Covarage",
                description: viewModel.coverageCount,
                size: .init(width: graphSize, height: graphSize)
            )
        }
    }
}
