//
//  GridGenerator.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import Foundation


// GridGenerator is responsible for converting a simple template
// into the actual game grid used by the app.
//
// The template only describes structure:
// true  -> block cell
// false -> playable cell
//
// This keeps puzzle layout separate from game logic.
// The generator builds proper Cell objects that the game can use.
struct GridGenerator {

    static func gridFromTemplate(_ template: [[Bool]]) -> [[Cell]] {

        // Final grid that will be returned to the game
        var grid: [[Cell]] = []

        // Loop through each row of the template
        for row in 0..<template.count {

            var currentRow: [Cell] = []

            // Loop through each column in the current row
            for col in 0..<template[row].count {

                // Every cell gets a fixed position in the grid
                let position = Position(row: row, col: col)

                // If template says true, create a block cell
                // Block cells hold sums later but cannot contain values
                if template[row][col] {
                    currentRow.append(
                        .block(position: position,
                               horizontalSum: nil,
                               verticalSum: nil)
                    )
                } else {

                    // Otherwise create a playable cell
                    // Playable cells hold user-entered numbers
                    currentRow.append(
                        .playable(position: position,
                                  value: nil)
                    )
                }
            }

            // Add completed row to the grid
            grid.append(currentRow)
        }

        // Return fully constructed grid
        return grid
    }
}


// GridSizing determines how large the grid should be
// based on difficulty and level.
//
// This keeps sizing rules in one place instead of spreading
// them across the setup logic or GameTracker.
struct GridSizing {

    static func size(
        for difficulty: GameDifficulty,
        level: Int
    ) -> (rows: Int, cols: Int) {

        // Difficulty controls general grid scale.
        // Early levels stay smaller to reduce complexity,
        // later levels increase size to raise difficulty.
        switch difficulty {

        case .easy:
            // Easy starts small, slightly increases after level 5
            return level <= 5 ? (5, 5) : (6, 6)

        case .medium:
            // Medium introduces larger grids earlier
            return level <= 5 ? (8, 8) : (10, 10)

        case .hard:
            // Hard uses large grids intended for longer solving time
            return level <= 5 ? (12, 12) : (15, 15)
        }
    }
}
