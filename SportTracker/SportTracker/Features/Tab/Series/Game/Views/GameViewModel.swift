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
