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

                    // Block cell
                    currentRow.append(
                        Cell(
                            position: position,
                            type: .block(horizontalSum: nil, verticalSum: nil),
                            value: nil
                        )
                    )

                } else {

                    // Playable cell
                    currentRow.append(
                        Cell(
                            position: position,
                            type: .playable,
                            value: nil
                        )
                    )
                }
            }

            grid.append(currentRow)
        }

        return grid
    }
}



