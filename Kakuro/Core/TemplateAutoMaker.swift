import Foundation

struct TemplateAutoMaker {

    // MARK: ENTRY POINT

    static func makeAllSets() {

        makeEasySets()
        makeMediumSets()
        makeHardSets()
    }

    // MARK: EASY

    static func makeEasySets() {

        let e5 = generateUniqueTemplates(
            count: 5,
            rows: 5,
            cols: 5,
            minIslands: 0,
            maxIslands: 1
        )

        let e6 = generateUniqueTemplates(
            count: 5,
            rows: 6,
            cols: 6,
            minIslands: 1,
            maxIslands: 2
        )

        print("\n// MARK: - EASY 5x5 (Levels 1-5) — AUTO-GENERATED VALID\n")
        print("static let easy5x5: [Int: [[Bool]]] = [")
        for i in 0..<e5.count {
            print("    \(i+1): \(asSwiftLiteral(e5[i])),")
        }
        print("]\n")

        print("\n// MARK: - EASY 6x6 (Levels 6-10) — AUTO-GENERATED VALID\n")
        print("static let easy6x6: [Int: [[Bool]]] = [")
        for i in 0..<e6.count {
            print("    \(i+6): \(asSwiftLiteral(e6[i])),")
        }
        print("]\n")
    }

    // MARK: MEDIUM

    static func makeMediumSets() {

        let m8 = generateUniqueTemplates(
            count: 5,
            rows: 8,
            cols: 8,
            minIslands: 2,
            maxIslands: 6
        )

        let m10 = generateUniqueTemplates(
            count: 5,
            rows: 10,
            cols: 10,
            minIslands: 4,
            maxIslands: 10
        )

        print("\n// MARK: - MEDIUM 8x8 (Levels 1-5) — AUTO-GENERATED VALID\n")
        print("static let medium8x8: [Int: [[Bool]]] = [")
        for i in 0..<m8.count {
            print("    \(i+1): \(asSwiftLiteral(m8[i])),")
        }
        print("]\n")

        print("\n// MARK: - MEDIUM 10x10 (Levels 6-10) — AUTO-GENERATED VALID\n")
        print("static let medium10x10: [Int: [[Bool]]] = [")
        for i in 0..<m10.count {
            print("    \(i+6): \(asSwiftLiteral(m10[i])),")
        }
        print("]\n")
    }

    // MARK: HARD

    static func makeHardSets() {

        let h12 = generateUniqueTemplates(
            count: 5,
            rows: 12,
            cols: 12,
            minIslands: 6,
            maxIslands: 14
        )

        let h15 = generateUniqueTemplates(
            count: 5,
            rows: 15,
            cols: 15,
            minIslands: 10,
            maxIslands: 22
        )

        print("\n// MARK: - HARD 12x12 (Levels 1-5) — AUTO-GENERATED VALID\n")
        print("static let hard12x12: [Int: [[Bool]]] = [")
        for i in 0..<h12.count {
            print("    \(i+1): \(asSwiftLiteral(h12[i])),")
        }
        print("]\n")

        print("\n// MARK: - HARD 15x15 (Levels 6-10) — AUTO-GENERATED VALID\n")
        print("static let hard15x15: [Int: [[Bool]]] = [")
        for i in 0..<h15.count {
            print("    \(i+6): \(asSwiftLiteral(h15[i])),")
        }
        print("]\n")
    }

    // MARK: CORE GENERATOR

    private static func generateUniqueTemplates(
        count: Int,
        rows: Int,
        cols: Int,
        minIslands: Int,
        maxIslands: Int
    ) -> [[[Bool]]] {

        var results: [[[Bool]]] = []
        var seen: Set<String> = []

        var safety = 0

        while results.count < count && safety < 200_000 {
            safety += 1

            var grid = blankTemplate(rows: rows, cols: cols)

            // IMPORTANT: create structure first
            seedStructure(&grid)

            let islands = Int.random(in: minIslands...maxIslands)


            for _ in 0..<islands {
                placeIsland(&grid)
            }

            guard TemplateValidator.isValid(grid) else { continue }

            let key = gridKey(grid)
            guard !seen.contains(key) else { continue }

            seen.insert(key)
            results.append(grid)
        }

        return results
    }

    // MARK: BASE GRID

    private static func blankTemplate(rows: Int, cols: Int) -> [[Bool]] {

        var g = Array(
            repeating: Array(repeating: false, count: cols),
            count: rows
        )

        // borders are blocks
        for r in 0..<rows {
            g[r][0] = true
            g[r][cols - 1] = true
        }

        for c in 0..<cols {
            g[0][c] = true
            g[rows - 1][c] = true
        }

        return g
    }

    // MARK: ISLAND PLACEMENT

    private static func placeIsland(_ g: inout [[Bool]]) {

        let rows = g.count
        let cols = g[0].count

        for _ in 0..<30 {

            let r = Int.random(in: 1..<(rows - 2))
            let c = Int.random(in: 1..<(cols - 2))

            let shape = Int.random(in: 0...2)

            // backup cells so we can undo safely
            let backup = g

            switch shape {

            case 0: // 2x2 block
                g[r][c] = true
                g[r][c+1] = true
                g[r+1][c] = true
                g[r+1][c+1] = true

            case 1: // vertical 1x2
                g[r][c] = true
                g[r+1][c] = true

            default: // horizontal 2x1
                g[r][c] = true
                g[r][c+1] = true
            }

            // validate immediately
            if TemplateValidator.isValid(g) {
                return
            }

            // undo if invalid
            g = backup
        }
    }


    private static func set(_ g: inout [[Bool]], _ r: Int, _ c: Int, _ v: Bool) {
        if r >= 0 && r < g.count && c >= 0 && c < g[0].count {
            g[r][c] = v
        }
    }

    // MARK: HELPERS
    private static func seedStructure(_ g: inout [[Bool]]) {

        let rows = g.count
        let cols = g[0].count

        // add a few guaranteed vertical separators
        for c in stride(from: 3, to: cols - 2, by: 4) {
            for r in 1..<(rows - 1) {
                if Bool.random() {
                    g[r][c] = true
                }
            }
        }

        // add a few horizontal separators
        for r in stride(from: 3, to: rows - 2, by: 4) {
            for c in 1..<(cols - 1) {
                if Bool.random() {
                    g[r][c] = true
                }
            }
        }
    }

    
    private static func gridKey(_ g: [[Bool]]) -> String {
        g.map { row in
            row.map { $0 ? "1" : "0" }.joined()
        }.joined(separator: "|")
    }

    private static func asSwiftLiteral(_ g: [[Bool]]) -> String {
        let rows = g.map { row in
            "[\(row.map { $0 ? "true" : "false" }.joined(separator: ","))]"
        }.joined(separator: ",\n        ")

        return "[\n        \(rows)\n    ]"
    }
}
