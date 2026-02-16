//
//  GridGenerator.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import Foundation


struct GridGenerator {

    static func gridFromTemplate(_ template: [[Bool]]) -> [[Cell]] {
        var grid: [[Cell]] = []

        for row in 0..<template.count {
            var currentRow: [Cell] = []

            for col in 0..<template[row].count {
                let position = Position(row: row, col: col)

                if template[row][col] {
                    currentRow.append(
                        .block(position: position,
                               horizontalSum: nil,
                               verticalSum: nil)
                    )
                } else {
                    currentRow.append(
                        .playable(position: position,
                                  value: nil)
                    )
                }
            }

            grid.append(currentRow)
        }

        return grid
    }
}


struct GridSizing {

    static func size(
        for difficulty: GameDifficulty,
        level: Int
    ) -> (rows: Int, cols: Int) {

        switch difficulty {

        case .easy:
            return level <= 5 ? (5, 5) : (6, 6)

        case .medium:
            return level <= 5 ? (8, 8) : (10, 10)

        case .hard:
            return level <= 5 ? (12, 12) : (15, 15)
        }
    }
}


