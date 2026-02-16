import Foundation

struct KakuroTemplates {
    
    static func template(for difficulty: GameDifficulty, level: Int) -> [[Bool]] {
        switch difficulty {
        case .easy:
            return (level <= 5) ? easy5x5[level] ?? easy5x5[1]! : easy6x6[level] ?? easy6x6[6]!
            
        case .medium:
            return (level <= 5) ? medium8x8[level] ?? medium8x8[1]! : medium10x10[level] ?? medium10x10[6]!
            
        case .hard:
            return (level <= 5) ? hard12x12[level] ?? hard12x12[1]! : hard15x15[level] ?? hard15x15[6]!
        }
    }
    
    
    
    // MARK: - EASY 5x5 (Levels 1-5) — VALID
    static let easy5x5_base: [[Bool]] = [
        [true,true,true,true,true],
        [true,false,false,false,true],
        [true,false,false,false,true],
        [true,false,false,false,true],
        [true,true,true,true,true],
    ]

    static let easy5x5: [Int: [[Bool]]] = [
        1: easy5x5_base,
        2: TemplateTransforms.mirrorH(easy5x5_base),
        3: TemplateTransforms.mirrorV(easy5x5_base),
        4: TemplateTransforms.rotate180(easy5x5_base),
        5: TemplateTransforms.mirrorH(
                TemplateTransforms.mirrorV(easy5x5_base)
            ),
    ]



    



    // MARK: - EASY 6x6 (Levels 6-10) — AUTO-GENERATED VALID

    static let easy6x6: [Int: [[Bool]]] = [
        6: [
            [true,true,true,true,true,true],
            [true,false,false,true,true,true],
            [true,false,false,true,true,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,true,true,true,true,true]
        ],
        7: [
            [true,true,true,true,true,true],
            [true,false,false,true,true,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,true,true,true,true,true]
        ],
        8: [
            [true,true,true,true,true,true],
            [true,true,true,false,false,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,true,true,true,true,true]
        ],
        9: [
            [true,true,true,true,true,true],
            [true,true,true,false,false,true],
            [true,true,true,false,false,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,true,true,true,true,true]
        ],
        10: [
            [true,true,true,true,true,true],
            [true,false,false,false,false,true],
            [true,false,false,false,false,true],
            [true,true,true,false,false,true],
            [true,true,true,false,false,true],
            [true,true,true,true,true,true]
        ],
    ]






    
 
    // MARK: - MEDIUM 8x8 (Levels 1-5) — AUTO-GENERATED VALID

    static let medium8x8: [Int: [[Bool]]] = [

        1: [
            [true,true,true,true,true,true,true,true],
            [true,false,false,true,true,false,false,true],
            [true,false,false,true,true,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,true,false,false,false,false,false,true],
            [true,true,false,false,false,false,false,true],
            [true,true,true,false,false,false,false,true],
            [true,true,true,true,true,true,true,true]
        ],

        2: [
            [true,true,true,true,true,true,true,true],
            [true,false,false,false,false,true,true,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,true,true,false,false,false,false,true],
            [true,true,true,false,false,true,true,true],
            [true,true,true,false,false,true,true,true],
            [true,true,true,true,true,true,true,true]
        ],

        3: [
            [true,true,true,true,true,true,true,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,true,true,true,true],
            [true,false,false,true,true,true,true,true],
            [true,false,false,true,true,true,true,true],
            [true,true,true,true,true,true,true,true]
        ],

        4: [
            [true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,true,true],
            [true,false,false,false,true,true,true,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,true,true],
            [true,false,false,false,false,true,true,true],
            [true,true,true,true,true,true,true,true]
        ],

        5: [
            [true,true,true,true,true,true,true,true],
            [true,true,true,false,false,false,false,true],
            [true,true,true,false,false,false,false,true],
            [true,false,false,false,true,true,true,true],
            [true,false,false,false,false,true,true,true],
            [true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true]
        ],
    ]



    

    
    // MARK: - MEDIUM 10x10 (Levels 6-10) — AUTO-GENERATED VALID

    static let medium10x10: [Int: [[Bool]]] = [

        6: [
            [true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,true,true,true,true,false,false,true],
            [true,false,false,true,true,true,true,false,false,true],
            [true,false,false,true,true,true,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true]
        ],

        7: [
            [true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,true,true,false,false,false,true],
            [true,false,false,true,true,true,true,false,false,true],
            [true,false,false,true,true,true,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true]
        ],

        8: [
            [true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,false,false,false,false,false,false,true],
            [true,true,true,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,false,false,false,true],
            [true,true,true,true,true,true,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true]
        ],

        9: [
            [true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,false,false,false,true],
            [true,false,false,false,true,true,false,false,false,true],
            [true,false,false,false,true,true,false,false,false,true],
            [true,false,false,false,true,true,true,true,true,true],
            [true,false,false,false,false,false,true,true,true,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true]
        ],

        10: [
            [true,true,true,true,true,true,true,true,true,true],
            [true,true,true,false,false,false,false,false,false,true],
            [true,true,true,false,false,false,false,false,false,true],
            [true,false,false,true,true,false,false,false,false,true],
            [true,false,false,true,true,true,true,false,false,true],
            [true,false,false,true,true,true,true,false,false,true],
            [true,false,false,false,false,true,true,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,false,false,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true]
        ],
    ]


    
 
    // MARK: - HARD 12x12 (Levels 1-5)

    static let hard12x12: [Int: [[Bool]]] = [
        1: [
            [true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,false,false,false,true,false,false,false,true],
            [true,false,false,true,false,false,false,true,false,false,false,true],
            [true,true,true,true,true,false,false,false,true,true,true,true],
            [true,false,false,true,true,false,false,false,true,false,false,true],
            [true,false,false,false,false,true,true,false,false,false,false,true],
            [true,false,false,false,false,false,false,true,false,false,true,true],
            [true,true,false,false,true,false,false,false,false,true,true,true],
            [true,true,false,false,false,true,false,false,true,false,false,true],
            [true,false,false,true,false,false,false,false,false,false,false,true],
            [true,false,false,true,true,false,false,true,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        2: [
            [true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,true,false,false,false,true],
            [true,false,false,false,true,false,false,false,false,false,false,true],
            [true,true,false,false,false,false,false,false,true,true,true,true],
            [true,true,true,false,false,true,true,false,false,false,true,true],
            [true,false,false,true,true,false,false,true,false,false,false,true],
            [true,false,false,true,false,false,false,true,true,false,false,true],
            [true,true,false,false,false,false,true,true,false,false,false,true],
            [true,true,true,false,false,false,false,true,false,false,true,true],
            [true,false,false,true,true,false,false,false,false,false,false,true],
            [true,false,false,true,true,false,false,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        3: [
            [true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,false,false,true,true,false,false,false,true],
            [true,false,false,true,false,false,false,true,false,false,false,true],
            [true,true,true,true,false,false,false,false,true,true,true,true],
            [true,false,false,true,false,false,false,false,false,true,true,true],
            [true,false,false,true,true,false,false,false,false,false,true,true],
            [true,false,false,false,false,true,false,false,false,false,false,true],
            [true,true,false,false,false,false,false,false,false,false,false,true],
            [true,true,false,false,false,false,false,true,true,false,false,true],
            [true,false,false,true,false,false,false,true,false,false,true,true],
            [true,false,false,true,false,false,true,true,false,false,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        4: [
            [true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,false,false,true,false,false,false,true],
            [true,false,false,false,true,false,false,true,false,false,false,true],
            [true,true,true,false,false,false,true,true,true,true,true,true],
            [true,false,false,false,false,true,false,false,false,true,true,true],
            [true,false,false,false,true,true,false,false,false,false,false,true],
            [true,true,true,false,false,true,true,true,false,false,false,true],
            [true,true,false,false,false,true,false,false,false,true,true,true],
            [true,false,false,true,false,false,false,false,true,false,false,true],
            [true,false,false,true,false,false,false,false,false,false,false,true],
            [true,false,false,true,false,false,false,false,false,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        5: [
            [true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,false,false,true,false,false,true],
            [true,false,false,true,false,false,false,false,false,false,false,true],
            [true,true,true,true,false,false,true,false,false,false,true,true],
            [true,false,false,true,false,false,true,true,false,false,false,true],
            [true,false,false,false,true,false,false,false,false,false,false,true],
            [true,true,true,false,false,true,false,false,true,true,true,true],
            [true,true,false,false,false,false,false,true,true,false,false,true],
            [true,true,false,false,true,false,false,false,false,false,false,true],
            [true,false,false,true,true,false,false,false,false,false,false,true],
            [true,false,false,true,true,false,false,true,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true]
        ],
    ]

    
    
    // MARK: - HARD 15x15 (Levels 6-10) — AUTO-GENERATED VALID

    static let hard15x15: [Int: [[Bool]]] = [
        6: [
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,true,true,true,false,false,false,true,true],
            [true,false,false,true,true,true,true,true,true,true,false,false,false,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,false,false,true,true,false,false,false,false,true],
            [true,false,false,false,true,true,false,false,true,true,false,false,false,false,true],
            [true,false,false,false,true,true,true,true,true,true,true,false,false,false,true],
            [true,false,false,false,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,false,false,true,true,true,false,false,true,true,true],
            [true,true,false,false,true,false,false,false,true,true,false,false,false,true,true],
            [true,true,false,false,true,true,false,false,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        7: [
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,true,false,false,true,false,false,false,true,true],
            [true,false,false,true,true,true,true,false,false,true,false,false,false,false,true],
            [true,true,true,true,true,true,true,false,false,true,false,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,false,false,false,true,true,true,true,true,true,true],
            [true,true,true,true,true,false,false,false,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,false,true,true,false,false,true,true,true],
            [true,false,false,false,true,true,true,true,true,true,false,false,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,false,true,true,true,false,false,false,true],
            [true,true,true,true,true,false,false,false,true,true,true,false,false,false,true],
            [true,true,true,true,true,true,false,false,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        8: [
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,false,false,false,true,true,true,true,false,false,true],
            [true,false,false,false,true,false,false,false,true,true,true,true,false,false,true],
            [true,false,false,false,true,false,false,false,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,true,true,false,false,true,true,true,true,true,true],
            [true,false,false,false,true,true,true,false,false,true,false,false,true,true,true],
            [true,true,true,true,true,true,true,false,false,true,false,false,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,false,false,false,true,true],
            [true,true,true,true,true,true,true,true,true,true,false,false,false,true,true],
            [true,false,false,true,true,false,false,true,true,true,true,false,false,false,true],
            [true,false,false,true,true,false,false,true,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        9: [
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,true,true,true,true,true,true,true,false,false,true],
            [true,false,false,false,true,true,false,false,true,true,true,true,false,false,true],
            [true,false,false,false,true,true,false,false,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,false,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,false,true,true,true,true,true,true,true],
            [true,false,false,false,true,false,false,true,true,true,true,true,false,false,true],
            [true,true,false,false,true,true,true,true,true,true,true,true,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,false,false,true,true,false,false,true,true,true,true,true,true,true],
            [true,true,false,false,true,true,false,false,true,true,true,false,false,false,true],
            [true,true,false,false,true,true,false,false,true,true,true,false,false,false,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        ],
        10: [
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,false,false,false,true],
            [true,true,true,true,true,false,false,false,false,true,true,false,false,false,true],
            [true,true,true,true,true,false,false,false,false,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,false,false,true,true,true,false,false,false,true,false,false,false,false,true],
            [true,false,false,true,true,true,false,false,false,true,false,false,false,false,true],
            [true,false,false,true,true,true,true,true,true,true,true,false,false,false,true],
            [true,false,false,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,false,false,false,true],
            [true,false,false,false,true,true,false,false,false,true,true,false,false,false,true],
            [true,false,false,false,true,true,false,false,false,true,false,false,true,true,true],
            [true,false,false,false,true,true,false,false,true,true,false,false,true,true,true],
            [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
        ],
    ]
    
    static func debugValidateAll() {
        for (lvl, t) in easy5x5 { if !TemplateValidator.isValid(t) { print("easy5x5 \(lvl) invalid") } }
        for (lvl, t) in easy6x6 { if !TemplateValidator.isValid(t) { print("easy6x6 \(lvl) invalid") } }
        for (lvl, t) in medium8x8 { if !TemplateValidator.isValid(t) { print("medium8x8  \(lvl) invalid") } }
        for (lvl, t) in medium10x10  { if !TemplateValidator.isValid(t) { print("medium10x10 \(lvl) invalid") } }
        // etc...
    }

}

struct TemplateTransforms {

    static func mirrorH(_ g: [[Bool]]) -> [[Bool]] {
        g.map { Array($0.reversed()) }
    }

    static func mirrorV(_ g: [[Bool]]) -> [[Bool]] {
        Array(g.reversed())
    }

    static func rotate180(_ g: [[Bool]]) -> [[Bool]] {
        mirrorV(mirrorH(g))
    }
}

struct TemplateValidator {

    static func isValid(_ grid: [[Bool]]) -> Bool {
        let rows = grid.count
        let cols = grid.first?.count ?? 0
        guard rows > 0, cols > 0 else { return false }

        // Rule: every playable must belong to a horizontal AND vertical run
        for r in 0..<rows {
            for c in 0..<cols {

                guard grid[r][c] == false else { continue }

                // count horizontal length
                var hLen = 1
                var cc = c - 1
                while cc >= 0 && !grid[r][cc] { hLen += 1; cc -= 1 }
                cc = c + 1
                while cc < cols && !grid[r][cc] { hLen += 1; cc += 1 }

                // count vertical length
                var vLen = 1
                var rr = r - 1
                while rr >= 0 && !grid[rr][c] { vLen += 1; rr -= 1 }
                rr = r + 1
                while rr < rows && !grid[rr][c] { vLen += 1; rr += 1 }

                if hLen < 2 || vLen < 2 {
                    return false
                }
            }
        }


        // Rule: top row & left col should be blocks (recommended for your clue anchoring system)
        for r in 0..<rows { if grid[r][0] == false { return false } }
        for c in 0..<cols { if grid[0][c] == false { return false } }

        // Rule: horizontal runs 2...9 only
        for r in 0..<rows {
            var len = 0
            for c in 0..<cols {
                if grid[r][c] { // block
                    if len == 1 || len > 9 { return false }
                    len = 0
                } else {
                    len += 1
                }
            }
            if len == 1 || len > 9 { return false }
        }

        // Rule: vertical runs 2...9 only
        for c in 0..<cols {
            var len = 0
            for r in 0..<rows {
                if grid[r][c] {
                    if len == 1 || len > 9 { return false }
                    len = 0
                } else {
                    len += 1
                }
            }
            if len == 1 || len > 9 { return false }
        }

        return true
    }
}
