//
//  Puzzle.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-03-12.
//

import Foundation


class Puzzle {

    var gridSize: [Int: [Bool]]
    var difficulty: GameDifficulty
    var level: Int

    var grid: [[Cell]] = []
    var solution: [Position: Int] = [:]
    var progress: [Position: Int] = [:]

   

    init(gridSize: [Int: [Bool]], difficulty: GameDifficulty, stageNumber: Int) {
        self.gridSize = gridSize
        self.difficulty = difficulty
        self.level = stageNumber
    }
    
    
    func enterNumber(_ value: Int, at position: Position) {
        progress[position] = value
    }
    func enterValue(_ value: Int, at position: Position) {
        progress[position] = value
    }

    func removeValue(at position: Position) {
        progress.removeValue(forKey: position)
    }
    
    func validate() -> Bool {
        for run in allRunSlices() {
            if !isRunCompleted(run) {
                return false
            }
        }
        return true
    }
   
    
    
    
    
    
    
    
    
    
    
    
    
    
    func findCell(at position: Position) -> Cell? {
        grid[position.row][position.col]
    }

    

   


    
    
    
    func horizontalRun(for position: Position) -> RunSlice? {

        let row = position.row
        var col = position.col

        while col > 0 {
            if case .block = grid[row][col - 1].type { break }
            col -= 1
        }

        let startCol = col
        var positions: [Position] = []

        while col < grid[row].count {
            let cell = grid[row][col]

            guard case .playable = cell.type else { break }

            positions.append(cell.position)
            col += 1
        }

        guard positions.count >= 2 else { return nil }

        let anchor = Position(row: row, col: startCol - 1)

        var target: Int?

        if anchor.col >= 0 {
            let anchorCell = grid[anchor.row][anchor.col]

            if case .block(let h, _) = anchorCell.type {
                target = h
            }
        }

        return RunSlice(
            direction: .horizontal,
            positions: positions,
            targetSum: target
        )
    }
    
    func verticalRun(for position: Position) -> RunSlice? {

        var row = position.row
        let col = position.col

        while row > 0 {
            if case .block = grid[row - 1][col].type { break }
            row -= 1
        }

        let startRow = row
        var positions: [Position] = []

        while row < grid.count {

            let cell = grid[row][col]

            guard case .playable = cell.type else { break }

            positions.append(cell.position)
            row += 1
        }

        guard positions.count >= 2 else { return nil }

        let anchor = Position(row: startRow - 1, col: col)

        var target: Int?

        if anchor.row >= 0 {
            let anchorCell = grid[anchor.row][anchor.col]

            if case .block(_, let v) = anchorCell.type {
                target = v
            }
        }

        return RunSlice(
            direction: .vertical,
            positions: positions,
            targetSum: target
        )
    }
    
    
    
    func runs(containing position: Position) -> [RunSlice] {
        cachedRuns.filter { $0.positions.contains(position) }
    }
    
    
    func allowedNumbers(for position: Position) -> Set<Int> {

        // Runs that affect this cell (one horizontal, one vertical)
        let cellRuns = runs(containing: position)

        // Step 1: eliminate digits already used in either run
        var forbidden: Set<Int> = []
        for run in cellRuns {
            forbidden.formUnion(usedNumbers(in: run.positions))
        }

        // Remaining candidates after duplicate removal
        var remaining = Set(1...9).subtracting(forbidden)

        // Step 2: enforce sum feasibility constraints
        for run in cellRuns {

            guard let targetSum = run.targetSum else { continue }

            let used = usedNumbers(in: run.positions)
            let usedSum = used.reduce(0, +)

            // Count empty cells including this one
            let empties = run.positions.filter {
                if $0 == position { return true }
                return progress[$0] == nil
            }.count

            if empties <= 0 { continue }

            remaining = Set(remaining.filter { candidate in

                if used.contains(candidate) { return false }

                let slotsLeft = empties - 1
                let sumAfterCandidate = usedSum + candidate
                let sumNeeded = targetSum - sumAfterCandidate

                if slotsLeft == 0 {
                    return sumNeeded == 0
                }

                let availableDigits =
                    Array(Set(1...9)
                        .subtracting(used)
                        .subtracting([candidate])).sorted()

                if availableDigits.count < slotsLeft { return false }

                let minPossible =
                    availableDigits.prefix(slotsLeft).reduce(0, +)

                let maxPossible =
                    availableDigits.suffix(slotsLeft).reduce(0, +)

                return (minPossible...maxPossible).contains(sumNeeded)
            })
        }

        return remaining
    }
    
    
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
            if let target = run.targetSum {
                let currentSum = values.reduce(0, +)
                if currentSum > target {
                    return true
                }
            }
        }

        return false
    }

    
    func isRunCompleted(_ run: RunSlice) -> Bool {

        guard let target = run.targetSum else {
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
    
    func allRunSlices() -> [RunSlice] {
        cachedRuns
    }
    
    
    
    func assignRunSumsToBlocks() {

        for run in allRunSlices() {

            let sum = run.positions.compactMap { value(at: $0) }.reduce(0, +)

            guard let first = run.positions.first else { continue }

            switch run.direction {

            case .horizontal:
                let anchor = Position(row: first.row, col: first.col - 1)
                setBlockSum(at: anchor, horizontal: sum)

            case .vertical:
                let anchor = Position(row: first.row - 1, col: first.col)
                setBlockSum(at: anchor, vertical: sum)
            }
        }
    }
    
    func isValidStructure() -> Bool {

        // 1) Every run must contain between 2 and 9 cells
        for run in allRunSlices() {
            if run.positions.count < 2 || run.positions.count > 9 {
                print("Invalid run length \(run.positions.count) dir=\(run.direction) run=\(run.positions)")
                return false
            }
        }

        // 2) Every playable cell must belong to one horizontal and one vertical run
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {

                let cell = grid[row][col]

                guard case .playable = cell.type else { continue }

                let pos = cell.position

                let hasH = horizontalRun(for: pos) != nil
                let hasV = verticalRun(for: pos) != nil

                if !hasH || !hasV {
                    print("Invalid cell \(pos): hasH=\(hasH) hasV=\(hasV)")
                    return false
                }
            }
        }

        return true
    }
    
    
    func generateSolution() -> Bool {

        // Collect all playable cells
        var playable: [Position] = []

        for r in 0..<grid.count {
            for c in 0..<grid[r].count {

                let cell = grid[r][c]

                if case .playable = cell.type {
                    playable.append(cell.position)
                }
            }
        }

        func allowedDigits(for pos: Position) -> [Int] {
            guard
                let hRun = horizontalRun(for: pos),
                let vRun = verticalRun(for: pos)
            else { return [] }

            let usedH = usedNumbers(in: hRun.positions)
            let usedV = usedNumbers(in: vRun.positions)

            return (1...9).filter {
                !usedH.contains($0) && !usedV.contains($0)
            }
        }

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

        func setCell(_ pos: Position, _ value: Int?) {

            if case .playable = grid[pos.row][pos.col].type {
                grid[pos.row][pos.col].value = value
            }
        }

        func backtrack(_ remaining: [Position]) -> Bool {

            if remaining.isEmpty { return true }

            guard let (pos, rest) = pickNextPosition(remaining)
            else { return false }

            let options = allowedDigits(for: pos).shuffled()

            for d in options {

                setCell(pos, d)

                if backtrack(rest) {
                    return true
                }

                setCell(pos, nil)
            }

            return false
        }

        let ok = backtrack(playable)

        if ok {

            var sol: [Position: Int] = [:]

            for pos in playable {

                let cell = grid[pos.row][pos.col]

                if case .playable = cell.type,
                   let v = cell.value {
                    sol[pos] = v
                }
            }

            solution = sol
        }

        return ok
    }
    
    
    func clearPlayableValuesForPuzzle() {

        for r in 0..<grid.count {
            for c in 0..<grid[r].count {

                if case .playable = grid[r][c].type {
                    grid[r][c].value = nil
                }
            }
        }
    }
    
    
    
    private func setBlockSum(
        at pos: Position,
        horizontal: Int? = nil,
        vertical: Int? = nil
    ) {

        var cell = grid[pos.row][pos.col]

        guard case .block(let h, let v) = cell.type else { return }

        let newH = horizontal ?? h
        let newV = vertical ?? v

        cell.type = .block(horizontalSum: newH, verticalSum: newV)

        grid[pos.row][pos.col] = cell
    }
    
    
    func usedNumbers(in positions: [Position]) -> Set<Int> {
        Set(positions.compactMap { progress[$0] })
    }
    
    
    private func value(at pos: Position) -> Int? {

        let cell = grid[pos.row][pos.col]

        guard case .playable = cell.type else {
            return nil
        }

        return cell.value
    }

    
    func isInCompletedRun(_ position: Position) -> Bool {
        let cellRuns = runs(containing: position)
        return cellRuns.contains { isRunCompleted($0) }
    }
    
    
    var cachedRuns: [RunSlice] = []
    func buildRuns() {
        cachedRuns.removeAll()

        let rows = grid.count
        let cols = grid.first?.count ?? 0

        for r in 0..<rows {
            for c in 0..<cols {

                let cell = grid[r][c]

                guard cell.isBlock else { continue }

                // horizontal run: any block followed by playable cells
                if c + 1 < cols, grid[r][c + 1].isPlayable {
                    var positions: [Position] = []
                    var x = c + 1

                    while x < cols && grid[r][x].isPlayable {
                        positions.append(Position(row: r, col: x))
                        x += 1
                    }

                    if positions.count >= 2 {
                        let target: Int?
                        if case .block(let h, _) = cell.type {
                            target = h
                        } else {
                            target = nil
                        }

                        cachedRuns.append(
                            RunSlice(
                                direction: .horizontal,
                                positions: positions,
                                targetSum: target
                            )
                        )
                    }
                }

                // vertical run: any block followed by playable cells
                if r + 1 < rows, grid[r + 1][c].isPlayable {
                    var positions: [Position] = []
                    var y = r + 1

                    while y < rows && grid[y][c].isPlayable {
                        positions.append(Position(row: y, col: c))
                        y += 1
                    }

                    if positions.count >= 2 {
                        let target: Int?
                        if case .block(_, let v) = cell.type {
                            target = v
                        } else {
                            target = nil
                        }

                        cachedRuns.append(
                            RunSlice(
                                direction: .vertical,
                                positions: positions,
                                targetSum: target
                            )
                        )
                    }
                }
            }
        }
    }

}
