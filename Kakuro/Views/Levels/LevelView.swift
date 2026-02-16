//
//  LevelView.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI

struct LevelView: View {
    @EnvironmentObject var gameTracker: GameTracker
    @State private var showCompletionSheet = false


    var body: some View {
        ZStack {

            GeometryReader { geo in
                let rows = gameTracker.grid.count
                let cols = gameTracker.grid.first?.count ?? 1

                let cellSize = min(
                    geo.size.width / CGFloat(cols),
                    geo.size.height / CGFloat(rows)
                )

                VStack(spacing: 0) {
                    ForEach(0..<gameTracker.grid.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(gameTracker.grid[row]) { cell in
                                CellView(cell: cell)
                                    .id(cell.id)
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }

                    Spacer().frame(height: 50)

                    HStack {
                        Spacer()
                        Numpad()
                        Spacer()
                        SpecialButtons()
                    }
                }
                .id(gameTracker.progress.count)
                .frame(
                    width: cellSize * CGFloat(cols),
                    height: cellSize * CGFloat(rows)
                )
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height / 2
                )
            }
            .padding()

            // ✅ COMPLETION POPUP
            if showCompletionSheet {
                CompletionView {
                    showCompletionSheet = false
                }
                .transition(.scale)
            }
        }
        .onChange(of: gameTracker.isCompleted) { completed in
            if completed {
                showCompletionSheet = true
            }
        }
    }

}


struct CompletionView: View {

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Congratulations")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Puzzle completed")
                    .foregroundStyle(.secondary)

                Button("OK") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            .padding(24)
            .frame(width: 260, height: 220)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 20)
        }
    }
}




#Preview {
    LevelView()
        .environmentObject(GameTracker())
}
