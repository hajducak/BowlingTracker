import SwiftUI

struct TooltipView: View {
    var info: String

    var body: some View {
        HStack(alignment: .top, spacing: Padding.spacingS) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color(.primary))
            Text(info)
                .subheading(color: .textSecondary, weight: .regular)
                .multilineTextAlignment(.leading)
        }.padding(.horizontal, Padding.defaultPadding)
    }
}
