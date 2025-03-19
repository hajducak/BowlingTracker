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
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel(game: Game()))
        .padding()
}

struct PinsGrid: View {
    @Binding var selectedPins: Set<Int>
    let disabledPins: Set<Int>
    
    let pinLayout: [[Int]] = [
        [7, 8, 9, 10],
        [4, 5, 6],
        [2, 3],
        [1]
    ]
    
    var body: some View {
        VStack(spacing: Padding.spacingXXM) {
            ForEach(pinLayout, id: \.self) { row in
                HStack(spacing: Padding.spacingXXM) {
                    ForEach(row, id: \.self) { pin in
                        PinView(
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
    let pin: Int
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text("\(pin)").bold()
            .frame(width: 40, height: 40)
            .background(isSelected ? Color(.primary) : isDisabled ? Color(.bgTerciary) : Color(.bgSecondary))
                .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.border), lineWidth: isSelected ? 0 : 1))
            .opacity(isDisabled ? 0.5 : 1.0)
            .tap {
                if !isDisabled {
                    onTap()
                }
            }
    }
}
