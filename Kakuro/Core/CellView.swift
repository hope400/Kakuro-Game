//
//  CellView.swift
//  Kakuro
//

import SwiftUI

struct CellView: View {

    let cell: Cell
    @EnvironmentObject var gameTracker: GameSession

    var body: some View {

        ZStack {

            switch cell.type {

            // MARK: BLOCK CELL
            case .block(let hSum, let vSum):

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ZStack {

                        Color.black

                        if hSum != nil || vSum != nil {
                            DiagonalSplit()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        }

                        if let hSum {
                            Text("\(hSum)")
                                .font(.system(size: min(w, h) * 0.28,
                                              weight: .semibold))
                                .foregroundColor(.white)
                                .position(x: w * 0.72, y: h * 0.28)
                        }

                        if let vSum {
                            Text("\(vSum)")
                                .font(.system(size: min(w, h) * 0.28,
                                              weight: .semibold))
                                .foregroundColor(.white)
                                .position(x: w * 0.28, y: h * 0.72)
                        }
                    }
                }


            // MARK: PLAYABLE CELL
            case .playable:

                let position = cell.position

                ZStack {

                    if gameTracker.puzzle.hasConflict(at: position) {
                        Color.red.opacity(0.8)
                    }
                    else if gameTracker.puzzle.isInCompletedRun(position) {
                        Color.green.opacity(0.8)
                    }
                    else if gameTracker.isInSelectedRun(position) {
                        Color.blue.opacity(0.5)
                    }
                    else {
                        Color.white
                    }

                    if let value = gameTracker.puzzle.progress[position] {
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold))
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                    }
                }
            }
        }

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

        .contentShape(Rectangle())

        .onTapGesture {
            if case .playable = cell.type {
                gameTracker.selectedCell = cell
            }
        }
    }
}


// MARK: - DiagonalSplit

struct DiagonalSplit: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}


// MARK: - Preview

#Preview {
    VStack {

        CellView(
            cell: Cell(
                position: Position(row: 0, col: 0),
                type: .block(horizontalSum: 23, verticalSum: 17),
                value: nil
            )
        )

        CellView(
            cell: Cell(
                position: Position(row: 0, col: 1),
                type: .block(horizontalSum: nil, verticalSum: nil),
                value: nil
            )
        )

        CellView(
            cell: Cell(
                position: Position(row: 1, col: 1),
                type: .playable,
                value: 5
            )
        )
    }
    .environmentObject(GameSession())
}
