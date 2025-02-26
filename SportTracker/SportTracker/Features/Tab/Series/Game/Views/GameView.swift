import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                SheetView(game: $viewModel.game)
                    .padding(.horizontal, Padding.defaultPadding)
            }
            Text("Select Fallen Pins")
                .font(.headline)
            PinsGrid(
                selectedPins: $viewModel.selectedPins,
                disabledPins: viewModel.disabledPins
            )
                .padding(.horizontal, Padding.defaultPadding)
                .padding(.bottom, Padding.defaultPadding)
            HStack(spacing: 4) {
                Button(action: viewModel.addRoll) {
                    Text("Add Roll")
                        .font(.title2).bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: viewModel.addStrike) {
                    Text("X")
                        .font(.title2).bold()
                        .padding()
                        .background(Color.orange)
                        .opacity(viewModel.strikeIsEnabled ? 1 : 0.3)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(!viewModel.strikeIsEnabled)
                Button(action: viewModel.addSpare) {
                    Text("/")
                        .font(.title2).bold()
                        .padding()
                        .background(Color.orange)
                        .opacity(viewModel.spareIsEnabled ? 1 : 0.3)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(!viewModel.spareIsEnabled)
            }
                .padding(.horizontal, Padding.defaultPadding)
            Button(action: viewModel.saveGame) {
                Text("Save Game")
                    .font(.title2).bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .opacity(viewModel.saveGameIsEnabled ? 1 : 0.3)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
                .padding(.horizontal, Padding.defaultPadding)
                .disabled(!viewModel.saveGameIsEnabled)
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
        VStack(spacing: 10) {
            ForEach(pinLayout, id: \.self) { row in
                HStack(spacing: 10) {
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
            .background(isSelected ? Color.orange : Color.gray.opacity(isDisabled ? 0.1 : 0.3))
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
