import Combine

class GameViewModel: ObservableObject {
    @Published var selectedPins: Set<Int> = []
    @Published var disabledPins: Set<Int> = []
    @Published var selectingFallenPins: Bool = true
    @Published var currentFrameIndex: Int = 0
    @Published var game: Game
    @Published var saveGameIsEnabled: Bool = false
    @Published var spareIsEnabled: Bool = false
    @Published var strikeIsEnabled: Bool = true
    @Published var addRollIsEnabled: Bool = true

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
                guard let lastUnfinishedFrame = game.frames.first(where: { $0.frameType == .unfinished }) else {
                    return (false, false)
                }
                let rolls = lastUnfinishedFrame.rolls
                let rollCount = rolls.count
                let totalPins = rolls.reduce(0) { $0 + $1.knockedDownPins.count }
                let isFirstRollStrike = rollCount > 0 && rolls[0].knockedDownPins.count == 10
                guard lastUnfinishedFrame.index != 10 else {
                    switch rollCount {
                    case 0: return (false, true)
                    case 1: return isFirstRollStrike ? (false, true) : (true, false)
                    case 2: return (rolls[1].knockedDownPins.count == 10 || totalPins == 10) ? (false, true) : (true, false)
                    default: return (false, false)
                    }
                }
                return (rollCount == 1, rollCount == 0)
            }
            .sink { [weak self] spareEnabled, strikeEnabled in
                self?.spareIsEnabled = spareEnabled
                self?.strikeIsEnabled = strikeEnabled
            }
            .store(in: &cancellables)

        $game
            .map { game in
                !game.frames.allSatisfy { $0.frameType != .unfinished }
            }
            .assign(to: \.addRollIsEnabled, on: self)
            .store(in: &cancellables)
    }

    func addRoll() {
        guard addRollIsEnabled else { return }
        
        var fallenPins: Set<Int> {
            self.disabledPins.isEmpty ? Set(1...10) : Set(1...10).subtracting(self.disabledPins)
        }

        let knockedDownPins = selectingFallenPins ? selectedPins.map { Pin(id: $0) } : fallenPins.subtracting(selectedPins).map { Pin(id: $0) }
        game.addRoll(knockedDownPins: knockedDownPins)
        
        disabledPins = selectingFallenPins ? selectedPins : Set(1...10).subtracting(selectedPins)
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
        } else if (rolls.count == 2 && lastFrame.frameType == .last) || rolls.count == 3 {
            disabledPins = Set(1...10)
        }
    }
    
    func addStrike() {
        guard strikeIsEnabled else { return }
        selectedPins = selectingFallenPins ? Set(1...10) : []
        addRoll()
    }

    func addSpare() {
        guard spareIsEnabled else { return }
        let enabledPins = selectingFallenPins ? Set(1...10).subtracting(disabledPins) : []
        selectedPins = enabledPins
        addRoll()
    }
    
    func saveGame() {
        gameSaved.send(game)
    }
}
