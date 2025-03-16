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
                    .tint(Color.orange)
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
            HStack(spacing: Padding.spacingXXS) {
                Button(action: viewModel.undoRoll) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                        .heading(color: .white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(Corners.corenrRadiusM)
                }
                Button(action: viewModel.addRoll) {
                    Text("Add Roll")
                        .heading(color: .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .opacity(viewModel.addRollIsEnabled ? 1 : 0.3)
                        .cornerRadius(Corners.corenrRadiusM)
                }.disabled(!viewModel.addRollIsEnabled)
                Button(action: viewModel.addStrike) {
                    Text("X")
                        .heading(color: .white)
                        .padding()
                        .background(Color.orange)
                        .opacity(viewModel.strikeIsEnabled ? 1 : 0.3)
                        .cornerRadius(Corners.corenrRadiusM)
                }.disabled(!viewModel.strikeIsEnabled)
                Button(action: viewModel.addSpare) {
                    Text("/")
                        .heading(color: .white)
                        .padding()
                        .background(Color.orange)
                        .opacity(viewModel.spareIsEnabled ? 1 : 0.3)
                        .cornerRadius(Corners.corenrRadiusM)
                }.disabled(!viewModel.spareIsEnabled)
            }
                .padding(.horizontal, Padding.defaultPadding)
            Button(action: viewModel.saveGame) {
                Text("Save Game")
                    .heading(color: .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .opacity(viewModel.saveGameIsEnabled ? 1 : 0.3)
                    .cornerRadius(Corners.corenrRadiusM)
            }
                .padding(.horizontal, Padding.defaultPadding)
                .disabled(!viewModel.saveGameIsEnabled)
            TextField("Enter lane numbers", text: $viewModel.gameLane)
                .textFieldStyle(labeled: "On lane")
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
            .background(isSelected ? Color.orange : isDisabled ? DefaultColor.grey6 : DefaultColor.grey4)
            .foregroundColor(isSelected ? .white : .black)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 1))
            .opacity(isDisabled ? 0.5 : 1.0)
            .tap {
                if !isDisabled {
                    onTap()
                }
            }
    }
}
