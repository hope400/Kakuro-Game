//
//  CellView.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI


// MARK: - CellView
//
// Responsible for rendering ONE cell of the Kakuro grid.
//
// This view does NOT contain game logic.
// It only reads state from:
// - Cell (what type of cell this is)
// - GameTracker (current game state)
//
// The grid view creates many CellViews, one per cell.
// Each CellView decides how to draw itself depending on:
//
// 1) The cell type (.block or .playable)
// 2) The game state (selected cell, conflicts, completed runs)
struct CellView: View {

    // The model describing this cell
    let cell: Cell

    
    // Shared game state injected from parent view.
    // GameTracker controls:
    // - selected cell
    // - conflicts
    // - completed runs
    // - highlighted runs
    @EnvironmentObject var gameTracker: GameTracker

    var body: some View {

        // ZStack allows background color + content + overlays
        ZStack {

            // The appearance changes depending on cell type
            switch cell {

            // MARK: BLOCK CELL (BLACK CELL WITH CLUES)
            //
            // Block cells may contain:
            // - horizontal sum (right direction)
            // - vertical sum (down direction)
            //
            // GeometryReader allows text and diagonal to scale
            // correctly regardless of cell size.
            case .block(_, let hSum, let vSum):

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ZStack {
                        // Base black background
                        Color.black

                        // Draw diagonal only if at least one clue exists
                        if hSum != nil || vSum != nil {
                            DiagonalSplit()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        }

                        // Horizontal clue (upper-right triangle)
                        if let hSum {
                            Text("\(hSum)")
                                .font(.system(size: min(w, h) * 0.28,
                                              weight: .semibold))
                                .foregroundColor(.white)
                                .position(
                                    x: w * 0.72,
                                    y: h * 0.28
                                )
                        }

                        // Vertical clue (lower-left triangle)
                        if let vSum {
                            Text("\(vSum)")
                                .font(.system(size: min(w, h) * 0.28,
                                              weight: .semibold))
                                .foregroundColor(.white)
                                .position(
                                    x: w * 0.28,
                                    y: h * 0.72
                                )
                        }
                    }
                }


            // MARK: PLAYABLE CELL (WHITE CELL)
            //
            // These are cells where the player enters numbers.
            // Visual appearance depends entirely on GameTracker state.
            case .playable(let position, _):

                ZStack {

                    // Background color priority:
                    //
                    // 1. Conflict → red
                    // 2. Completed run → green
                    // 3. Selected run → blue
                    // 4. Default → white
                    //
                    // Order matters here. First match wins.
                    if gameTracker.hasConflict(at: position) {
                        Color.red.opacity(0.8)
                    }
                    else if gameTracker.isInCompletedRun(position) {
                        Color.green.opacity(0.8)
                    }
                    else if gameTracker.isInSelectedRun(position) {
                        Color.blue.opacity(0.5)
                    }
                    else {
                        Color.white
                    }

                    // Display entered value if it exists
                    // nil means empty cell
                    if let value = gameTracker.progress[position] {
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold))
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                    }

                }
            }
        }

        // MARK: Selection Border
        //
        // Draws a border around the currently selected cell.
        // Uses cell.id (derived from position) to compare identity.
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(
                    gameTracker.selectedCell?.id == cell.id
                        ? Color.blue
                        : Color.gray,
                    lineWidth: 2
                )
        )

        // Ensures entire rectangle is tappable
        .contentShape(Rectangle())

        // MARK: Tap Handling
        //
        // Only playable cells can be selected.
        // Selection is stored in GameTracker,
        // which triggers UI updates across the grid.
        .onTapGesture {
            if case .playable = cell {
                gameTracker.selectedCell = cell
            }
        }
    }
}


// MARK: - DiagonalSplit Shape
//
// Custom shape used only by block cells.
// Draws the diagonal line separating clue areas.
struct DiagonalSplit: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}


// MARK: - Preview
//
// Simple preview showing different cell types.
// Uses a dummy GameTracker so preview compiles.
#Preview {
    VStack {
        CellView(
            cell: .block(
                position: Position(row: 0, col: 0),
                horizontalSum: 23,
                verticalSum: 17
            )
        )
        CellView(
            cell: .block(
                position: Position(row: 0, col: 1),
                horizontalSum: nil,
                verticalSum: nil
            )
        )
        CellView(
            cell: .playable(
                position: Position(row: 1, col: 1),
                value: 5
            )
        )
    }
    .environmentObject(GameTracker())
}
