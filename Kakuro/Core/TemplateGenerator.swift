//
//  TemplateGenerator.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-05.
//
import Foundation


struct TemplateGenerator {

    static func generate(
        rows: Int,
        cols: Int,
        difficulty: GameDifficulty,
        count: Int
    ) -> [[[Bool]]] {

        var templates: [[[Bool]]] = []
        var seed = rows * 1000 + cols * 10 + difficulty.hashValue

        while templates.count < count {
            let template = stripedTemplate(
                rows: rows,
                cols: cols,
                seed: seed
            )

            if isValidTemplate(template) {
                templates.append(template)
            }

            seed += 1
        }

        return templates
    }

    // MARK: - Structured striping

    private static func stripedTemplate(
        rows: Int,
        cols: Int,
        seed: Int
    ) -> [[Bool]] {

        var grid = Array(
            repeating: Array(repeating: false, count: cols),
            count: rows
        )

        // anchor row + col
        for r in 0..<rows {
            grid[r][0] = true
        }
        for c in 0..<cols {
            grid[0][c] = true
        }

        srand48(seed)

        // vertical stripes
        for c in stride(from: 2, to: cols, by: 3) {
            for r in 1..<rows {
                if drand48() < 0.35 {
                    grid[r][c] = true
                }
            }
        }

        // horizontal stripes
        for r in stride(from: 2, to: rows, by: 3) {
            for c in 1..<cols {
                if drand48() < 0.35 {
                    grid[r][c] = true
                }
            }
        }

        return grid
    }

    // MARK: - Validation

    private static func isValidTemplate(_ grid: [[Bool]]) -> Bool {
        let rows = grid.count
        let cols = grid[0].count

        func runLengths(_ isBlock: (Int, Int) -> Bool) -> Bool {
            for r in 0..<rows {
                var length = 0
                for c in 0..<cols {
                    if isBlock(r, c) {
                        if length == 1 || length > 9 { return false }
                        length = 0
                    } else {
                        length += 1
                    }
                }
                if length == 1 || length > 9 { return false }
            }
            return true
        }

        let horizontalOK = runLengths { r, c in grid[r][c] }
        let verticalOK = runLengths { r, c in grid[c][r] }

        return horizontalOK && verticalOK
    }
}
