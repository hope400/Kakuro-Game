//
//  CellInfo.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import Foundation

// MARK: - Position
//
// Represents a single coordinate inside the Kakuro grid.
// Every cell in the puzzle has a row and column index.
//
// This struct is used throughout the app to:
// - Identify where a cell exists in the grid
// - Compare cells
// - Store positions in collections (Dictionary / Set)
//
// Hashable allows Position to be used as a key in dictionaries
// or stored in Sets safely.
struct Position: Hashable, Codable {

    // Row index in the grid (top to bottom)
    let row: Int

    // Column index in the grid (left to right)
    let col: Int

    // Unique identifier built from row and column.
    // Example: "3-5"
    //
    // Used by SwiftUI and other systems that need a stable ID
    // for diffing and updating views efficiently.
    var id: String {
        "\(row)-\(col)"
    }
}


// MARK: - Cell
//
// Represents a single cell inside the Kakuro grid.
//
// A Kakuro board contains two types of cells:
// 1. Block cells → black cells that may contain clues (sums)
// 2. Playable cells → white cells where the player enters numbers
//
// This enum allows both types to be stored in the same grid
// while keeping their behavior and data separate.
enum Cell: Identifiable, Codable {

    // MARK: Block Cell
    //
    // A black cell that may contain clue numbers.
    //
    // horizontalSum → sum for cells to the RIGHT
    // verticalSum   → sum for cells BELOW
    //
    // Example:
    //   [ 16\ ] means vertical sum = 16
    //   [ \24 ] means horizontal sum = 24
    //   [16\24] means both directions exist
    case block(
        position: Position,
        horizontalSum: Int?,
        verticalSum: Int?
    )

    // MARK: Playable Cell
    //
    // A white cell where the user inputs a number.
    //
    // value is optional because:
    // - nil means empty cell
    // - Int means player has entered a number
    case playable(
        position: Position,
        value: Int?
    )

    // MARK: Identifiable
    //
    // SwiftUI requires a stable identifier when rendering lists
    // or grids of views. Both block and playable cells use their
    // grid position as the unique identity.
    var id: String {
        switch self {
        case .block(let position, _, _),
             .playable(let position, _):
            return position.id
        }
    }

    // MARK: Position Accessor
    //
    // Convenience property so other parts of the app do not need
    // to switch on the enum just to know where the cell is located.
    //
    // Used by:
    // - Grid rendering (CellView)
    // - Game logic
    // - Template generation
    var position: Position {
        switch self {
        case .block(let position, _, _),
             .playable(let position, _):
            return position
        }
    }
}
