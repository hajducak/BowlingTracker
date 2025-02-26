import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var selectedPins: Set<Int> = []
    @Published var disabledPins: Set<Int> = []
    @Published var currentFrameIndex: Int = 0
    @Published var game: Game
    @Published var saveGameIsEnabled: Bool = false
    @Published var spareIsEnabled: Bool = false
    @Published var strikeIsEnabled: Bool = true
    private var cancellables = Set<AnyCancellable>()

    let gameSaved = PassthroughSubject<Game, Never>()

    init(game: Game) {
        self.game = game

        $game
            .map { $0.frames.allSatisfy { $0.frameType != .unfinished } }
            .assign(to: \.saveGameIsEnabled, on: self)
            .store(in: &cancellables)
        
        $game
            .map { game in
                let lastUnfinishedFrame = game.frames.first { $0.frameType == .unfinished }
                return (
                    // FIXME: last frame not working properly with disabling X and /
                    lastUnfinishedFrame?.rolls.count == 1,
                    (
                        lastUnfinishedFrame?.rolls.isEmpty ?? false ||
                        lastUnfinishedFrame?.rolls.count == 2 ||
                        (
                            lastUnfinishedFrame?.rolls.count == 1 &&
                            lastUnfinishedFrame?.rolls[0].knockedDownPins.count == 10
                        )
                    )
                )
            }
            .sink { [weak self] spareEnabled, strikeEnabled in
                self?.spareIsEnabled = spareEnabled
                self?.strikeIsEnabled = strikeEnabled
            }
            .store(in: &cancellables)

    }

    func addRoll() {
        let knockedDownPins = selectedPins.map { Pin(id: $0) }
        game.addRoll(knockedDownPins: knockedDownPins)
        
        disabledPins = selectedPins
        selectedPins.removeAll()
        
        if game.frames.first(where: { $0.frameType == .unfinished })?.rolls.isEmpty == true {
            disabledPins.removeAll()
            return
        }
        
        guard let lastFrame = game.frames.first(where: { $0.index == 10 }), !lastFrame.rolls.isEmpty else { return }
        
        let rolls = lastFrame.rolls
        let totalPins = rolls.reduce(0) { $0 + $1.knockedDownPins.count }
        
        if rolls.isEmpty || (rolls.count == 1 && totalPins == 10) || (rolls.count == 2 && totalPins == 10) || (rolls.count == 2 && totalPins == 20) {
            disabledPins.removeAll()
        } else if rolls.count == 3 {
            disabledPins = Set(1...10)
        }
    }
    
    func addStrike() {
        selectedPins = Set(1...10)
        addRoll()
    }

    func addSpare() {
        let enabledPins = Set(1...10).subtracting(disabledPins)
        selectedPins = enabledPins
        addRoll()
    }
    
    func saveGame() {
        gameSaved.send(game)
    }
}

struct RollView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                GameView(game: $viewModel.game)
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
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: viewModel.addStrike) {
                    Text("X")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .opacity(viewModel.strikeIsEnabled ? 1 : 0.3)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(!viewModel.strikeIsEnabled)
                Button(action: viewModel.addSpare) {
                    Text("/")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .opacity(viewModel.spareIsEnabled ? 1 : 0.3)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }.disabled(!viewModel.spareIsEnabled)
            }
                .padding(.horizontal, Padding.defaultPadding)
            Button(action: viewModel.saveGame) {
                Text("Save Game")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
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
    RollView(viewModel: GameViewModel(game: Game()))
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
        Text("\(pin)")
            .frame(width: 40, height: 40)
            .background(isSelected ? Color.red : Color.gray.opacity(isDisabled ? 0.1 : 0.3))
            .foregroundColor(.black)
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
