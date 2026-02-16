//
//  GameTracker.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//
import Foundation
import SwiftUI
import Combine


// GameTracker is the central state object for the Kakuro game.
// It owns the grid, puzzle configuration, and logical structures
// derived from the grid (runs, lookup tables, solution, etc).
//
// Because it conforms to ObservableObject, SwiftUI views that
// observe this object automatically refresh when @Published
// properties change.
final class GameTracker: ObservableObject {

    // The current Kakuro grid being displayed.
    // Each element represents either a block cell or a playable cell.
    //
    // This is the main source of truth for the current game state.
    // All reads and writes to cell values happen here.
    @Published var grid: [[Cell]] = []

    // The currently selected cell in the UI.
    // Used to determine where input goes and which runs are highlighted.
    @Published var selectedCell: Cell?

    // Current difficulty level.
    // Determines which template pool is used when generating puzzles.
    @Published var difficulty: GameDifficulty = .easy

    // Current level within a difficulty.
    // Used to vary templates or complexity progression.
    @Published var level: Int = 1

    // All detected runs in the grid.
    // A run is a continuous sequence of playable cells sharing a sum.
    // Runs are generated after the grid is loaded.
    @Published var runs: [Run] = []

    // Lookup dictionary:
    // maps a position to the horizontal run it belongs to.
    // Allows fast access without scanning all runs.
    @Published var hRunByPos: [Position: UUID] = [:]

    // Lookup dictionary:
    // maps a position to the vertical run it belongs to.
    @Published var vRunByPos: [Position: UUID] = [:]

    // Cached templates used during generation.
    // Prevents repeated expensive template generation when
    // difficulty or level changes frequently.
    private var cachedTemplates: [[[Bool]]] = []


    // Stores the solved grid after generation.
    // This allows the playable values to be cleared while
    // still keeping the correct solution internally.
    @Published var solution: [Position: Int] = [:]
    @Published var progress: [Position: Int] = [:]

    
    
    init() {
        if !loadGame() {
            generatePuzzle()
            saveGame()
        }
    }

    @Published var isCompleted: Bool = false
    
    private var saveKey: String {
        "savedKakuroGame_\(difficulty.rawValue)_\(level)"
    }


    var isPuzzleComplete: Bool {
        progress.count == solution.count &&
        progress.allSatisfy { solution[$0.key] == $0.value }
    }
    
    @Published var completedLevels: [GameDifficulty: Set<Int>] = [:]



    // MARK: - Grid Loading

    // Loads a template based on difficulty and level,
    // converts it into a grid of Cell objects,
    // then generates logical runs from the structure.
    //
    // This is typically called when starting a new puzzle.
    func loadGrid() {
        let template = KakuroTemplates.template(for: difficulty, level: level)
        grid = GridGenerator.gridFromTemplate(template)
        generateRuns()
    }


    // MARK: - Difficulty Handling

    // Updates difficulty and clears cached templates.
    // Templates must be regenerated because layout rules
    // differ between difficulty levels.
    func setDifficulty(_ newDifficulty: GameDifficulty) {
        difficulty = newDifficulty
        cachedTemplates.removeAll()

        if !loadGame() {
            generatePuzzle()
            saveGame()
        }
    }



    // MARK: - Level Handling

    // Updates the current level and clears cached templates.
    // Ensures the next generation uses the correct template set.
    func setLevel(_ newLevel: Int) {
        level = newLevel
        cachedTemplates.removeAll()

        if !loadGame() {
            generatePuzzle()
            saveGame()
        }
    }





    // Returns true if the given position belongs to the same run
    // as the currently selected cell.
    //
    // Used by the UI to highlight all cells in the active run
    // when a playable cell is selected.
    //
    // Example:
    // If the user selects a cell in a horizontal run,
    // every cell in that run will be visually highlighted.
    func isInSelectedRun(_ position: Position) -> Bool {
        guard
            let selected = selectedCell,
            case .playable(let selectedPos, _) = selected
        else { return false }

        // Find all runs that contain the selected position
        let selectedRuns = runs(containing: selectedPos)

        // Return true if the queried position exists
        // in any of those runs.
        return selectedRuns.contains { $0.positions.contains(position) }
    }


    // Sets a numeric value in the currently selected playable cell.
    //
    // Rules enforced here:
    // - A cell must be selected
    // - The selected cell must be playable
    // - The cell must currently be empty
    //
    // The grid is treated as the source of truth,
    // so we always read from it before writing.
    func setValue(_ value: Int) {
        guard
            let cell = selectedCell,
            case .playable(let position, _) = cell
        else { return }

        guard progress[position] == nil else { return }

        progress[position] = value

        if isPuzzleComplete {
            isCompleted = true
            completedLevels[difficulty, default: []].insert(level)
        }

        saveGame()
    }





    // Clears the value from the currently selected playable cell.
    //
    // Used when the player deletes a number.
    func removeValue() {
        guard
            let cell = selectedCell,
            case .playable(let position, _) = cell
        else { return }

        progress.removeValue(forKey: position)

        // if they delete something, puzzle isn't complete anymore
        if isCompleted && !isPuzzleComplete {
            isCompleted = false
        }

        saveGame()
    }



    // Returns the target sum for a given run.
    //
    // Kakuro runs do not store their own sum directly.
    // Instead, the sum is stored in the adjacent block cell.
    //
    // Horizontal run → block immediately to the left
    // Vertical run   → block immediately above
    func runSum(for run: Run) -> Int? {
        guard let first = run.positions.first else { return nil }

        switch run.direction {

        case .horizontal:
            // Anchor block sits left of first playable cell
            let anchor = Position(row: first.row, col: first.col - 1)

            if case .block(_, let h, _) =
                grid[anchor.row][anchor.col] {
                return h
            }
            return nil

        case .vertical:
            // Anchor block sits above first playable cell
            let anchor = Position(row: first.row - 1, col: first.col)

            if case .block(_, _, let v) =
                grid[anchor.row][anchor.col] {
                return v
            }
            return nil
        }
    }


    // Calculates which numbers are allowed in the selected cell.
    //
    // Constraints enforced:
    // 1. No duplicate digits within a run
    // 2. Remaining empty cells must still be able to reach
    //    the required run sum.
    //
    // This prevents impossible moves before they happen.
    func allowedNumbers() -> Set<Int> {

        // Must have a selected playable cell
        guard
            let cell = selectedCell,
            case .playable(let pos, _) = cell
        else { return [] }

        // Runs that affect this cell (one horizontal, one vertical)
        let cellRuns = runs(containing: pos)

        // Step 1: eliminate digits already used in either run
        var forbidden: Set<Int> = []
        for run in cellRuns {
            forbidden.formUnion(usedNumbers(in: run.positions))
        }

        // Remaining candidates after duplicate removal
        var remaining = Set(1...9).subtracting(forbidden)

        // Step 2: enforce sum feasibility constraints
        for run in cellRuns {

            guard let targetSum = runSum(for: run) else { continue }

            let used = usedNumbers(in: run.positions)
            let usedSum = used.reduce(0, +)

            // Count empty cells including this one.
            // Needed to determine remaining sum flexibility.
            let empties = run.positions.filter {
                if $0 == pos { return true }
                return progress[$0] == nil

            
            }.count

            if empties <= 0 { continue }

            // Test each candidate number.
            // Keep only those that still allow the run to reach its target sum.
            remaining = Set(remaining.filter { candidate in

                // Safety check (already filtered above)
                if used.contains(candidate) { return false }

                let slotsLeft = empties - 1
                let sumAfterCandidate = usedSum + candidate
                let sumNeeded = targetSum - sumAfterCandidate

                // If this is the last empty slot,
                // the sum must match exactly.
                if slotsLeft == 0 {
                    return sumNeeded == 0
                }

                // Remaining digits available for this run
                let availableDigits =
                    Array(Set(1...9)
                    .subtracting(used)
                    .subtracting([candidate])).sorted()

                if availableDigits.count < slotsLeft { return false }

                // Minimum and maximum sums achievable
                // with remaining digits.
                let minPossible =
                    availableDigits.prefix(slotsLeft).reduce(0, +)

                let maxPossible =
                    availableDigits.suffix(slotsLeft).reduce(0, +)

                return (minPossible...maxPossible).contains(sumNeeded)
            })
        }

        return remaining
    }





    // Returns all runs (horizontal or vertical number groups)
    // that include the given position.
    func runs(containing position: Position) -> [Run] {
        runs.filter { $0.positions.contains(position) }
    }


    // Returns the set of numbers already used in the given positions.
    // This helps prevent duplicate numbers inside a run.
    func usedNumbers(in positions: [Position]) -> Set<Int> {
        Set(positions.compactMap { progress[$0] })
    }



     // Creates all horizontal runs in the grid.
     // A run is a sequence of playable cells between blocks.
     // Only runs with 2 or more cells are valid.
    func generateHorizontalRuns() -> [Run] {
        var result: [Run] = []

        // Go through each row in the grid
        for row in 0..<grid.count {
            var current: [Position] = []

            // Check each column in the row
            for col in 0..<grid[row].count {
                let cell = grid[row][col]

                switch cell {
                case .playable:
                    // Add playable cells to the current run
                    current.append(Position(row: row, col: col))

                case .block:
                    // When a block is reached, finish the current run
                    if current.count >= 2 {
                        result.append(
                            Run(direction: .horizontal, positions: current)
                        )
                    }
                    current = []
                }
            }

            // If the row ends while building a run, save it
            if current.count >= 2 {
                result.append(
                    Run(direction: .horizontal, positions: current)
                )
            }
        }

        return result
    }


    // Creates all vertical runs in the grid.
    // Works the same as horizontal runs, but scans column by column.
    func generateVerticalRuns() -> [Run] {
        var result: [Run] = []

        let rows = grid.count
        let cols = grid.first?.count ?? 0

        // Go through each column
        for col in 0..<cols {
            var current: [Position] = []

            // Check each row in the column
            for row in 0..<rows {
                let cell = grid[row][col]

                switch cell {
                case .playable:
                    current.append(Position(row: row, col: col))

                case .block:
                    // Finish run when a block is reached
                    if current.count >= 2 {
                        result.append(
                            Run(direction: .vertical, positions: current)
                        )
                    }
                    current = []
                }
            }

            // Save run if column ends while building one
            if current.count >= 2 {
                result.append(
                    Run(direction: .vertical, positions: current)
                )
            }
        }

        return result
    }


    // Builds all runs for the current grid.
    // Also creates quick lookup tables so we can quickly
    // find which run a position belongs to.
    func generateRuns() {
        runs = generateHorizontalRuns() + generateVerticalRuns()

        var h: [Position: UUID] = [:]
        var v: [Position: UUID] = [:]

        // For every run, remember which positions belong to it
        for run in runs {
            for pos in run.positions {
                switch run.direction {
                case .horizontal: h[pos] = run.id
                case .vertical:   v[pos] = run.id
                }
            }
        }

        hRunByPos = h
        vRunByPos = v
    }


    // Generates a full valid solution for the puzzle.
    // Uses backtracking to try numbers until a valid configuration is found.
    func generateSolution() -> Bool {

        // Collect all playable cells in the grid
        var playable: [Position] = []
        for r in 0..<grid.count {
            for c in 0..<grid[r].count {
                if case .playable(let p, _) = grid[r][c] {
                    playable.append(p)
                }
            }
        }

        // Tracks which numbers are already used in each run
        var usedInRun: [UUID: Set<Int>] = [:]

        // Returns digits allowed in this position
        // based on numbers already used in its runs
        func allowedDigits(for pos: Position) -> [Int] {
            guard let hID = hRunByPos[pos], let vID = vRunByPos[pos] else { return [] }
            let usedH = usedInRun[hID, default: []]
            let usedV = usedInRun[vID, default: []]
            return (1...9).filter { !usedH.contains($0) && !usedV.contains($0) }
        }

        // Chooses the next position to fill.
        // Picks the cell with the fewest valid options first,
        // which speeds up solving.
        func pickNextPosition(_ remaining: [Position]) -> (Position, [Position])? {
            var bestPos: Position?
            var bestOptionsCount = Int.max

            for pos in remaining {
                let opts = allowedDigits(for: pos)
                if opts.isEmpty { return nil }
                if opts.count < bestOptionsCount {
                    bestOptionsCount = opts.count
                    bestPos = pos
                    if bestOptionsCount == 1 { break }
                }
            }

            guard let chosen = bestPos else { return nil }
            var rest = remaining
            rest.removeAll { $0 == chosen }
            return (chosen, rest)
        }

        // Sets or clears a value in a playable cell
        func setCell(_ pos: Position, _ value: Int?) {
            if case .playable(let p, _) = grid[pos.row][pos.col] {
                grid[pos.row][pos.col] = .playable(position: p, value: value)
            }
        }

        // Recursive solver.
        // Tries allowed numbers and backtracks if a choice fails.
        func backtrack(_ remaining: [Position]) -> Bool {
            if remaining.isEmpty { return true }

            guard let (pos, rest) = pickNextPosition(remaining) else { return false }
            guard let hID = hRunByPos[pos], let vID = vRunByPos[pos] else { return false }

            var options = allowedDigits(for: pos).shuffled()

            for d in options {
                // apply number
                usedInRun[hID, default: []].insert(d)
                usedInRun[vID, default: []].insert(d)
                setCell(pos, d)

                if backtrack(rest) { return true }

                // undo if it leads to a dead end
                usedInRun[hID]?.remove(d)
                usedInRun[vID]?.remove(d)
                setCell(pos, nil)
            }

            return false
        }

        let ok = backtrack(playable)

        // If successful, store the completed solution
        if ok {
            var sol: [Position: Int] = [:]
            for pos in playable {
                if case .playable(_, let v) = grid[pos.row][pos.col], let v {
                    sol[pos] = v
                }
            }
            solution = sol
        }

        return ok
    }

    // Returns the current value stored at a playable position.
    // If the cell is not playable, nil is returned.
    private func value(at pos: Position) -> Int? {
        if case .playable(_, let v) = grid[pos.row][pos.col] {
            return v
        }
        return nil
    }


    // Updates the sum values stored in a block cell.
    // A block can have a horizontal sum, a vertical sum, or both.
    // Only the provided values are changed — existing values are kept.
    private func setBlockSum(at pos: Position, horizontal: Int? = nil, vertical: Int? = nil) {
        guard case .block(_, let h, let v) = grid[pos.row][pos.col] else { return }

        let newH = horizontal ?? h
        let newV = vertical ?? v

        grid[pos.row][pos.col] = .block(
            position: pos,
            horizontalSum: newH,
            verticalSum: newV
        )
    }


    // Calculates the total for each run and assigns it
    // to the correct block cell that acts as the clue.
    // Horizontal runs store their sum in the block to the left.
    // Vertical runs store their sum in the block above.
    func assignRunSumsToBlocks() {
        for run in runs {
            let sum = run.positions.compactMap { value(at: $0) }.reduce(0, +)
            guard let first = run.positions.first else { continue }

            switch run.direction {
            case .horizontal:
                // The clue block is immediately left of the run
                let anchor = Position(row: first.row, col: first.col - 1)
                setBlockSum(at: anchor, horizontal: sum)

            case .vertical:
                // The clue block is immediately above the run
                let anchor = Position(row: first.row - 1, col: first.col)
                setBlockSum(at: anchor, vertical: sum)
            }
        }
    }


    // Clears all numbers from playable cells.
    // The solution remains stored separately,
    // but the grid is reset for the player to solve.
    func clearPlayableValuesForPuzzle() {
        for r in 0..<grid.count {
            for c in 0..<grid[r].count {
                if case .playable(let p, _) = grid[r][c] {
                    grid[r][c] = .playable(position: p, value: nil)
                }
            }
        }
    }


    // Checks that the grid structure is valid before solving.
    // Ensures runs are the correct size and that every playable
    // cell belongs to both a horizontal and vertical run.
    func isValidStructure() -> Bool {

        // 1) Every run must contain between 2 and 9 cells
        for run in runs {
            if run.positions.count < 2 || run.positions.count > 9 {
                print("Invalid run length \(run.positions.count) dir=\(run.direction) run=\(run.positions)")
                return false
            }
        }

        // 2) Every playable cell must belong to one horizontal
        // and one vertical run.
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                guard case .playable(let pos, _) = grid[row][col] else { continue }

                let hasH = hRunByPos[pos] != nil
                let hasV = vRunByPos[pos] != nil

                if !hasH || !hasV {
                    print("Invalid cell \(pos): hasH=\(hasH) hasV=\(hasV)")
                    return false
                }
            }
        }

        return true
    }


    // Main puzzle generation process.
    // This prepares the grid, generates a valid solution,
    // assigns clue sums, then clears the grid so the player
    // receives an unsolved puzzle.
    func generatePuzzle() {

        // Reset game state before generating a new puzzle
        selectedCell = nil
        solution.removeAll()
        progress.removeAll()
        runs.removeAll()
        hRunByPos.removeAll()
        vRunByPos.removeAll()
        isCompleted = false

        // Load the template grid
        loadGrid()

        // Ensure the template structure is valid before continuing
        guard isValidStructure() else {
            print("Invalid template")
            return
        }

        // Clear any existing values before solving
        clearPlayableValuesForPuzzle()

        // Generate a full valid solution
        guard generateSolution() else {
            print("Could not solve template")
            return
        }

        // Assign sums to block cells based on the solution
        assignRunSumsToBlocks()

        // Remove numbers again so the player can solve it
        clearPlayableValuesForPuzzle()

        // Save the generated puzzle state
        saveGame()
    }


    
    // Calculates a difficulty score for a single run.
    // Shorter runs are generally harder because there are fewer placement options.
    // Runs with larger sums are also slightly harder.
    func runDifficultyScore(_ run: Run) -> Int {

        // Shorter runs increase difficulty
        let lengthScore = max(0, 6 - run.positions.count)

        // Larger totals are considered harder
        let sum = run.positions.compactMap { solution[$0] }.reduce(0, +)
        let sumScore = sum > 20 ? 2 : 0

        return lengthScore + sumScore
    }


    // Calculates the overall puzzle difficulty
    // by adding up the difficulty score of all runs.
    func difficultyScore() -> Int {
        runs.map(runDifficultyScore).reduce(0, +)
    }


    // Checks whether placing a value at a position creates a conflict.
    // A conflict happens when:
    // - a number is duplicated inside a run
    // - or the current sum exceeds the target sum.
    func hasConflict(at position: Position) -> Bool {

        guard let value = progress[position] else {
            return false
        }

        let cellRuns = runs(containing: position)

        for run in cellRuns {

            // Collect all current values in this run
            let values = run.positions.compactMap {
                progress[$0]
            }

            // Check for duplicate numbers
            if values.filter({ $0 == value }).count > 1 {
                return true
            }

            // Check if the sum has exceeded the target
            if let target = runSum(for: run) {
                let currentSum = values.reduce(0, +)
                if currentSum > target {
                    return true
                }
            }
        }

        return false
    }



    // Returns true when a run is fully and correctly completed.
    // A run is complete when:
    // - every cell has a value
    // - there are no duplicates
    // - the sum matches the target value.
    func isRunCompleted(_ run: Run) -> Bool {

        guard let target = runSum(for: run) else {
            return false
        }

        var values: [Int] = []

        for pos in run.positions {
            guard let v = progress[pos] else {
                return false
            }
            values.append(v)
        }

        // Duplicate numbers are not allowed
        if Set(values).count != values.count {
            return false
        }

        // Check if total matches the required sum
        return values.reduce(0, +) == target
    }


    // Checks whether a position belongs to a run
    // that has already been correctly completed.
    // Useful for highlighting finished runs in the UI.
    func isInCompletedRun(_ position: Position) -> Bool {
        let cellRuns = runs(containing: position)
        return cellRuns.contains { isRunCompleted($0) }
    }


    // Attempts to load a previously saved game from local storage.
    // Returns true if a saved game was found and restored,
    // or false if no saved data exists.
    func loadGame() -> Bool {

        // Try to read saved data and decode it into a SavedGame object
        guard
            let data = UserDefaults.standard.data(forKey: saveKey),
            let saved = try? JSONDecoder().decode(SavedGame.self, from: data)
        else {
            return false
        }

        // Restore the saved game state
        grid = saved.grid
        solution = saved.solution
        progress = saved.progress
        difficulty = saved.difficulty
        level = saved.level
        isCompleted = saved.isCompleted
        completedLevels = saved.completedLevels

        // UI-related state should not be restored
        // (for example, which cell was selected previously)
        selectedCell = nil

        // Rebuild runs and lookup tables based on the restored grid
        generateRuns()

        return true
    }


    // Saves the current game state to local storage.
    // This allows the player to continue later from where they left off.
    func saveGame() {

        let save = SavedGame(
            grid: grid,
            solution: solution,
            progress: progress,
            difficulty: difficulty,
            level: level,
            isCompleted: isCompleted,
            completedLevels: completedLevels
        )

        // Encode the game data and store it in UserDefaults
        if let data = try? JSONEncoder().encode(save) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    
    
    

}


enum GameDifficulty: String, Codable {
    case easy
    case medium
    case hard
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
