import Foundation

struct HardTemplateAutoMaker {

    // MARK: ENTRY

    static func makeHardSets() {

        // ---- 12x12 ----
//        let hard12 = generateFromBase(
//            base: hard12x12_base,
//            count: 5,
//            mutations: 250
//        )
//
//        print("\n// MARK: - HARD 12x12 (Levels 1-5)\n")
//        print("static let hard12x12: [Int: [[Bool]]] = [")
//
//        for i in 0..<hard12.count {
//            print("    \(i+1): \(asSwiftLiteral(hard12[i])),")
//        }
//
//        print("]\n")


        // ---- 15x15 ----
        let hard15 = generateFromBase(
            base: hard15x15_base,
            count: 5,
            mutations: 60     // larger grid → more mutations
        )

        print("\n// MARK: - HARD 15x15 (Levels 6-10)\n")
        print("static let hard15x15: [Int: [[Bool]]] = [")
        
     

        for i in 0..<hard15.count {
            
            print("    \(i+6): \(asSwiftLiteral(hard15[i])),")
        }

        print("]\n")
    }


    // MARK: CORE IDEA

    private static func generateFromBase(
        base: [[Bool]],
        count: Int,
        mutations: Int
    ) -> [[[Bool]]] {

        var results: [[[Bool]]] = []
        var seen: Set<String> = []

        while results.count < count {

            let mutated = mutateFromBase(base, attempts: mutations)

            guard TemplateValidator.isValid(mutated) else { continue }

            let key = gridKey(mutated)
            guard !seen.contains(key) else { continue }

            seen.insert(key)
            results.append(mutated)
        }

        return results
    }

    // MARK: SAFE MUTATION

    private static func mutateFromBase(
        _ base: [[Bool]],
        attempts: Int
    ) -> [[Bool]] {

        var grid = base
        let rows = grid.count
        let cols = grid[0].count

        for _ in 0..<attempts {

            let r = Int.random(in: 1..<(rows-1))
            let c = Int.random(in: 1..<(cols-1))

            let old = grid[r][c]
            grid[r][c] = !old

            // only keep mutation if valid
            if !TemplateValidator.isValid(grid) {
                grid[r][c] = old
            }
        }

        return grid
    }

    // MARK: BASE TEMPLATE (your known-valid one)

//    static let hard12x12_base: [[Bool]] = [
//        [true,true,true,true,true,true,true,true,true,true,true,true],
//        [true,false,false,true,false,false,false,true,false,false,false,true],
//        [true,false,false,true,false,false,false,true,false,false,false,true],
//        [true,true,true,true,false,false,true,true,true,true,true,true],
//        [true,false,false,true,false,false,false,false,false,false,false,true],
//        [true,false,false,false,true,false,false,false,false,false,false,true],
//        [true,false,false,false,false,true,false,false,false,false,false,true],
//        [true,false,false,false,false,false,false,true,true,false,false,true],
//        [true,false,false,true,false,false,false,false,true,false,false,true],
//        [true,false,false,true,false,false,false,false,false,false,false,true],
//        [true,false,false,true,false,false,false,true,false,false,false,true],
//        [true,true,true,true,true,true,true,true,true,true,true,true]
//    ]
    
    
    
    static let hard15x15_base: [[Bool]] = [
        [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],

        [true,false,false,true,false,false,true,false,false,true,false,false,true,false,true],
        [true,false,false,false,false,true,false,false,false,false,false,true,false,false,true],
        [true,true,false,false,true,false,false,true,false,false,true,false,false,true,true],

        [true,false,false,true,false,false,false,false,true,false,false,false,true,false,true],
        [true,false,true,false,false,true,false,false,false,false,true,false,false,false,true],
        [true,false,false,false,true,false,false,false,true,false,false,false,true,false,true],

        [true,true,false,false,false,false,true,false,false,false,false,true,false,false,true],

        [true,false,false,true,false,false,false,false,false,true,false,false,false,true,true],
        [true,false,false,false,false,true,false,false,true,false,false,true,false,false,true],

        [true,false,true,false,false,false,false,true,false,false,false,false,false,true,true],
        [true,false,false,false,true,false,false,false,false,true,false,false,true,false,true],

        [true,true,false,false,true,false,false,true,false,false,false,true,false,false,true],
        [true,false,false,true,false,false,false,false,true,false,false,false,false,false,true],

        [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true],
    ]


    // MARK: HELPERS

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
