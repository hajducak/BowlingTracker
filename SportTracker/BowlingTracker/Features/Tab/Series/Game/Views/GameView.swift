import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                SheetView(game: $viewModel.game)
                    .padding(.horizontal, Padding.defaultPadding)
                    .padding(.bottom, Padding.spacingS)
            }.padding(.top, Padding.spacingXS)
            HStack(alignment: .center, spacing: Padding.spacingS) {
                Toggle("", isOn: $viewModel.selectingFallenPins)
                    .tint(Color(.primary))
                    .frame(width: 50)
                    .padding(.trailing, Padding.spacingXXM)
                Text("Select \(viewModel.selectingFallenPins ? "Fallen Pins" : "Left Over Pins")")
                    .heading()
                    .multilineTextAlignment(.trailing)
                Spacer()
            }.padding(.horizontal, Padding.defaultPadding)
            PinsGrid(
                selectedPins: $viewModel.selectedPins,
                disabledPins: viewModel.disabledPins
            )
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.bottom, Padding.defaultPadding)
            HStack(spacing: Padding.spacingS) {
                PrimaryButton(
                    leadingImage: Image(systemName: "chevron.backward"),
                    title: "Back",
                    isLoading: false,
                    isEnabled: true,
                    isInfinity: false,
                    horizontalPadding: Padding.spacingM,
                    action: viewModel.undoRoll
                )
                PrimaryButton(
                    title: "Add Roll",
                    isLoading: false,
                    isEnabled: viewModel.addRollIsEnabled,
                    action: viewModel.addRoll
                )
                PrimaryButton(
                    title: "X",
                    isLoading: false,
                    isEnabled: viewModel.strikeIsEnabled,
                    isInfinity: false,
                    horizontalPadding: Padding.spacingM,
                    action: viewModel.addStrike
                )
                PrimaryButton(
                    title: "/",
                    isLoading: false,
                    isEnabled: viewModel.spareIsEnabled,
                    isInfinity: false,
                    horizontalPadding: Padding.spacingM,
                    action: viewModel.addSpare
                )
            }
                .padding(.horizontal, Padding.defaultPadding)
            PrimaryButton(
                title: "Save Game",
                isLoading: false,
                isEnabled: viewModel.saveGameIsEnabled,
                action: viewModel.saveGame
            )
                .padding(.horizontal, Padding.defaultPadding)
            TextField("Enter lane numbers", text: $viewModel.gameLane)
                .defaultTextFieldStyle(labeled: "On lane")
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.top, Padding.spacingS)
            TextField("Enter ball name", text: $viewModel.gameBallName)
                .defaultTextFieldStyle(labeled: "With ball")
                .padding(.horizontal, Padding.defaultPadding)
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel(game: Game()))
        .padding()
}

struct PinsGrid: View {
    var pinSize: CGSize = .init(width: 40, height: 40)
    var contentSpacing: CGFloat = Padding.spacingXXM
    @Binding var selectedPins: Set<Int>
    let disabledPins: Set<Int>
    
    let pinLayout: [[Int]] = [
        [7, 8, 9, 10],
        [4, 5, 6],
        [2, 3],
        [1]
    ]
    
    var body: some View {
        VStack(spacing: contentSpacing) {
            ForEach(pinLayout, id: \.self) { row in
                HStack(spacing: contentSpacing) {
                    ForEach(row, id: \.self) { pin in
                        PinView(
                            size: pinSize,
                            pin: pin,
                            isSelected: selectedPins.contains(pin),
                            isDisabled: disabledPins.contains(pin)
                        ) {
                            togglePin(pin)
                        }
                    }
                }
            }
        }
    }
    
    private func togglePin(_ pin: Int) {
        if !disabledPins.contains(pin) {
            if selectedPins.contains(pin) {
                selectedPins.remove(pin)
            } else {
                selectedPins.insert(pin)
            }
        }
    }
}

struct PinView: View {
    var size: CGSize
    let pin: Int
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    private var fontSize: CGFloat {
        let defaultWidth: CGFloat = 40
        let defaultFontSize: CGFloat = 18
        let ratio = size.width / defaultWidth
        return defaultFontSize * ratio
    }
    
    var body: some View {
        Text("\(pin)").bold()
            .frame(width: size.width, height: size.height)
            .custom(size: fontSize, color: isDisabled ? .textSecondary : .textPrimary)
            .background(isSelected ? Color(.primary) : isDisabled ? Color(.bgSecondary) : Color(.bgTerciary))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.border), lineWidth: isSelected ? 0 : 1))
            .opacity(isDisabled ? DefaultOpacity.disabled : 1.0)
            .tap {
                if !isDisabled {
                    onTap()
                }
            }
    }
}
