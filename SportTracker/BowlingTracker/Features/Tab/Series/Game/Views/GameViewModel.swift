import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var selectedPins: Set<Int> = []
    @Published var disabledPins: Set<Int> = []
    @Published var selectingFallenPins: Bool = false
    @Published var currentFrameIndex: Int = 0
    @Published var game: Game
    @Published var gameLane: String = ""
    @Published var selectedBall: Ball?
    @Published var selectedSpareBall: Ball?
    @Published var saveGameIsEnabled: Bool = false
    @Published var spareIsEnabled: Bool = false
    @Published var strikeIsEnabled: Bool = true
    @Published var addRollIsEnabled: Bool = true
    @Published var user: User

    private var cancellables = Set<AnyCancellable>()
    let gameSaved = PassthroughSubject<Game, Never>()

    init(game: Game, user: User) {
        self.game = game
        self.user = user

        $game.combineLatest($gameLane)
            .map { $0.frames.allSatisfy { $0.frameType != .unfinished } && !$1.isEmpty }
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
        // 10th frame:
        guard let lastFrame = game.frames.first(where: { $0.index == 10 }), !lastFrame.rolls.isEmpty else { return }
        
        let rolls = lastFrame.rolls
        let totalPins = rolls.reduce(0) { $0 + $1.knockedDownPins.count }
        
        if rolls.isEmpty || (rolls.count == 1 && totalPins == 10) || (rolls.count == 2 && totalPins == 10) || (rolls.count == 2 && totalPins == 20) {
            disabledPins.removeAll()
        } else if (rolls.count == 2 && lastFrame.frameType == .last) || rolls.count == 3 {
            disabledPins = Set(1...10)
        }
    }

    func undoRoll() {
        game.undoRoll()
        
        selectedPins.removeAll()
        disabledPins.removeAll()
        
        guard let currentFrame = game.frames.first(where: { $0.frameType == .unfinished }) else { return }
        if currentFrame.index != 10 {
            disabledPins = Set(currentFrame.rolls.flatMap { $0.knockedDownPins.map { $0.id } })
            return
        }
       
        // 10th frame:
        let rolls = currentFrame.rolls
        let rollCount = rolls.count
        guard rollCount != 0 else { return }

        let knockedDownPins = rolls[rollCount - 1].knockedDownPins.map { $0.id }

        if rollCount == 1 {
            disabledPins = knockedDownPins.count == 10 ? [] : Set(knockedDownPins)
        } else if rollCount == 2 {
            let totalPins = rolls[0].knockedDownPins.count + knockedDownPins.count
            disabledPins = (totalPins == 10 || totalPins == 20) ? [] : Set(knockedDownPins)
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
        game.lane = gameLane
        game.ballId = selectedBall?.id
        game.spareBallId = selectedSpareBall?.id
        gameSaved.send(game)
    }
    
    func onAddBall() {
        NotificationCenter.default.post(name: .selectProfileTab, object: nil)
        NotificationCenter.default.post(name: .addBallRequested, object: nil)
    }
    
    deinit {
        gameSaved.send(completion: .finished)
        cancellables.removeAll()
    }
}
