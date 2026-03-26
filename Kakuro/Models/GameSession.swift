//
//  GameTracker.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//
import Foundation
import SwiftUI
import Combine


final class GameSession: ObservableObject {
    @Published var puzzle: Puzzle
    @Published var selectedCell: Cell?
    @Published var difficulty: GameDifficulty = .easy
    @Published var level: Int = 1
    @Published var moveCount: Int = 0
    @Published var statistics = Statistics()
    weak var firebaseManager: FirebaseManager?
    @Published var isGuestMode: Bool = false
    private(set) var startTime: Date?
    private(set) var endTime: Date?
    private var redoMemory: [Position: Int] = [:]
    
   
    func setGuestMode(_ enabled: Bool){
        isGuestMode = enabled
    }
    
    func loadPuzzle(completion: @escaping () -> Void) {

    guard let firebaseManager else {
        let local = KakuroTemplates.template(for: difficulty, level: level)
        puzzle.grid = GridGenerator.gridFromTemplate(local)
        completion()
        return
    }

    firebaseManager.fetchTemplate(
        difficulty: difficulty,
        level: level
    ) { [weak self] template in

        guard let self else { return }

        DispatchQueue.main.async {

            if let template {
                self.puzzle.grid = GridGenerator.gridFromTemplate(template)
            } else {
                let local = KakuroTemplates.template(
                    for: self.difficulty,
                    level: self.level
                )
                self.puzzle.grid = GridGenerator.gridFromTemplate(local)
            }

            completion()
        }
    }
}
    
    
    
    
    func validateAccess(for difficulty: GameDifficulty) -> Bool {
        
        if isGuestMode && difficulty == .hard {
            return false
        }
        
        return true
    }
    
    func setValue(_ value: Int) {
        guard
            let cell = selectedCell,
            cell.isPlayable
        else { return }

        let position = cell.position
        let previous = puzzle.progress[position]

        redoMemory.removeValue(forKey: position)

        puzzle.enterValue(value, at: position)
        moveCount += 1

        print("progress:", puzzle.progress.count, "solution:", puzzle.solution.count)
        print("isPuzzleComplete:", puzzle.validate())

        if puzzle.validate() {
            print("Puzzle complete triggered")
            isCompleted = true
            stopTimer()

            let time = elapsedTime
            statistics.recordWin(time: time, moves: moveCount)

            print("Saving stats to Firebase...")

            if !isGuestMode {
                Task {
                    try await firebaseManager?.saveStatistics(statistics)
                }
            }

            completedLevels[difficulty, default: []].insert(level)
        }

        saveGame()
    }
    
    
    
    func undoEntry() {

        guard
            let cell = selectedCell,
            cell.isPlayable
        else { return }

        let position = cell.position

        guard let value = puzzle.progress[position] else { return }

        // store value for redo
        redoMemory[position] = value

        puzzle.removeValue(at: position)

        moveCount += 1
        saveGame()
    }
    
    func redoEntry() {

        guard
            let cell = selectedCell,
            cell.isPlayable
        else { return }

        let position = cell.position

        guard let value = redoMemory[position] else { return }

        puzzle.enterValue(value, at: position)

        // clear redo after restoring
        redoMemory.removeValue(forKey: position)

        moveCount += 1
        saveGame()
    }
    
    
    func startTimer(){
        startTime = Date()
        endTime = nil
    }
    func stopTimer(){
        endTime = Date()
    }
    
    func saveGame() {

        let save = SavedGame(
            grid: puzzle.grid,
            solution: puzzle.solution,
            progress: puzzle.progress,
            difficulty: difficulty,
            level: level,
            isCompleted: isCompleted,
            completedLevels: completedLevels
        )

        
        if let data = try? JSONEncoder().encode(save) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func filterStatistics(for difficulty: GameDifficulty) -> Statistics {
        statistics
    }
    
    
    
    
    
    
    
    
    
    
    
    
    private var pauseStart: Date?
    private var totalPausedDuration: TimeInterval = 0
    
    
   
    
    
    var timeLimit: TimeInterval {
        switch difficulty {
        case .easy:
            return 8 * 60
        case .medium:
            return 12 * 60
        case .hard:
            return 15 * 60
        }
    }
    
    var remainingTime: TimeInterval {

        guard let start = startTime else {
            return timeLimit
        }

        let elapsed = Date().timeIntervalSince(start) - totalPausedDuration
        let remaining = timeLimit - elapsed

        return max(remaining, 0)
    }
    
    var isTimeExpired: Bool {
        remainingTime <= 0
    }
  
    
    var isWarningTime: Bool {
        remainingTime <= 30 && remainingTime > 10
    }

    var isCriticalTime: Bool {
        remainingTime <= 10
    }
    
    
    func updateTimer() {

        if isTimeExpired && !isCompleted {
            handleTimeExpired()
        }
    }
    
    func pauseTimer() {
        pauseStart = Date()
    }

    func resumeTimer() {
        guard let pauseStart else { return }

        totalPausedDuration += Date().timeIntervalSince(pauseStart)
        self.pauseStart = nil
    }
    
    
    init() {
        self.puzzle = Puzzle(gridSize: [:], difficulty: .easy, stageNumber: 1)
        
       

        if loadGame() {
            puzzle.buildRuns()
            return
        }

        generatePuzzle()
    }

    @Published var isCompleted: Bool = false
    
    private var saveKey: String {
        "savedKakuroGame_\(difficulty.rawValue)_\(level)"
    }


 
    
    
    @Published var completedLevels: [GameDifficulty: Set<Int>] = [:]

    
    
    //MARK: NEW SYSTEM------------------------------------------------------------------
  
   
    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }

        if let end = endTime {
            return end.timeIntervalSince(start)
        }

        return Date().timeIntervalSince(start)
    }

   

    

    
    func isInSelectedRun(_ position: Position) -> Bool {
        guard
            let selected = selectedCell,
            case .playable = selected.type
        else { return false }

        let selectedPos = selected.position

        // Find all runs that contain the selected position
        let selectedRuns = puzzle.runs(containing: selectedPos)

        // Return true if the queried position exists
        // in any of those runs.
        return selectedRuns.contains { $0.positions.contains(position) }
    }
    
    
  
    
    
 
    
    

    
    func loadGame() -> Bool {

        // Try to read saved data and decode it into a SavedGame object
        guard
            let data = UserDefaults.standard.data(forKey: saveKey),
            let saved = try? JSONDecoder().decode(SavedGame.self, from: data)
        else {
            return false
        }

        // Restore the saved game state
        puzzle.grid = saved.grid
        puzzle.buildRuns()      // rebuild geometry from the template
        puzzle.solution = saved.solution
        puzzle.progress = saved.progress
        difficulty = saved.difficulty
        level = saved.level
        isCompleted = saved.isCompleted
        completedLevels = saved.completedLevels

        // UI-related state should not be restored
        // (for example, which cell was selected previously)
        selectedCell = nil


        return true
    }
    
    func runDifficultyScore(_ run: RunSlice) -> Int {

        // Shorter runs increase difficulty
        let lengthScore = max(0, 6 - run.positions.count)

        // Larger totals are considered harder
        let sum = run.positions.compactMap { puzzle.solution[$0] }.reduce(0, +)
        let sumScore = sum > 20 ? 2 : 0

        return lengthScore + sumScore
    }


    func difficultyScore() -> Int {
        puzzle.allRunSlices().map(runDifficultyScore).reduce(0, +)
    }

   
    //----------------------------------------------------------------------------------------

    func setDifficulty(_ newDifficulty: GameDifficulty) {
        difficulty = newDifficulty
        puzzle.difficulty = newDifficulty

        if !loadGame() {
            generatePuzzle()
        }
    }

    func setLevel(_ newLevel: Int) {
        level = newLevel
        puzzle.level = newLevel

        if !loadGame() {
            generatePuzzle()
        }
    }



    func formattedElapsedTime() -> String {
        let totalSeconds = Int(elapsedTime)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

  

    


    func handleTimeExpired() {
        guard !isCompleted else { return }

        isCompleted = true
        stopTimer()
        statistics.recordLoss(moves: moveCount)

        if !isGuestMode {
            Task {
                try await firebaseManager?.saveStatistics(statistics)
            }
        }
    }



    // Clears the value from the currently selected playable cell.
    //
    // Used when the player deletes a number.
    func removeValue() {
        guard
            let cell = selectedCell,
            case .playable = cell.type,
            let value = puzzle.progress[cell.position]
        else { return }

        let position = cell.position

        redoMemory[position] = value

        puzzle.removeValue(at: position)
        moveCount += 1

        if isCompleted {
            isCompleted = false
        }

        saveGame()
    }


 
    func canUndo() -> Bool {
        guard let cell = selectedCell, cell.isPlayable else { return false }
        return puzzle.progress[cell.position] != nil
    }

    func canRedo() -> Bool {
        guard let cell = selectedCell, cell.isPlayable else { return false }
        return redoMemory[cell.position] != nil
    }

   
    func generatePuzzle() {

        selectedCell = nil
        puzzle.solution.removeAll()
        puzzle.progress.removeAll()
        isCompleted = false

        loadPuzzle { [weak self] in
            guard let self else { return }

            guard self.puzzle.isValidStructure() else {
                print("Invalid template")
                return
            }

            self.puzzle.buildRuns()

            // blank playable cells before solving
            self.puzzle.clearPlayableValuesForPuzzle()

            guard self.puzzle.generateSolution() else {
                print("Could not solve template")
                return
            }

            self.puzzle.assignRunSumsToBlocks()

            // rebuild runs again so cached target sums are updated
            self.puzzle.buildRuns()

            self.puzzle.clearPlayableValuesForPuzzle()

            self.moveCount = 0
            self.startTimer()
            self.saveGame()
        }
    }


  

 

 
 

    func selectDifficulty(_ difficulty: GameDifficulty) -> Bool {
        
        if validateAccess(for: difficulty) {
            self.difficulty = difficulty
            return true
        }
        
        return false
    }
    
    func validateLevelAccess(level: Int) -> Bool {

        if isGuestMode && level > 5 {
            return false
        }

        return true
    }

    func selectLevel(_ level: Int) -> Bool {

        if !validateLevelAccess(level: level) {
            return false
        }

        self.level = level
        return true
    }


    

    
    
    

}




struct SavedGame: Codable {
    let grid: [[Cell]]
    let solution: [Position: Int]
    let progress: [Position: Int]
    let difficulty: GameDifficulty
    let level: Int
    let isCompleted: Bool
    let completedLevels: [GameDifficulty: Set<Int>]


}


enum RunDirection {
    case horizontal
    case vertical
}
struct RunSlice {
    let direction: RunDirection
    let positions: [Position]
    let targetSum: Int?
}
