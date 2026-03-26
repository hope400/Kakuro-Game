//
//  LevelView.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct LevelView: View {
    @EnvironmentObject var gameTracker: GameSession
    @State private var showCompletionSheet = false
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {

            GeometryReader { geo in
                let rows = gameTracker.puzzle.grid.count
                let cols = gameTracker.puzzle.grid.first?.count ?? 1

                let cellSize = min(
                    geo.size.width / CGFloat(cols),
                    geo.size.height / CGFloat(rows)
                )

                VStack(spacing: 0) {

                    GameTimerView()

                    Spacer()

                    ForEach(0..<gameTracker.puzzle.grid.count, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(gameTracker.puzzle.grid[row]) { cell in
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
                .id(gameTracker.puzzle.progress.count)
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

            if showCompletionSheet {
                CompletionView {
                    showCompletionSheet = false
                    dismiss()
                }
                .transition(.scale)
            }
        }
        .onDisappear { gameTracker.pauseTimer() }
        .onAppear {

            if !gameTracker.loadGame() {
                gameTracker.generatePuzzle()
            }

            if gameTracker.startTime == nil {
                gameTracker.startTimer()
            } else {
                gameTracker.resumeTimer()
            }

            if gameTracker.isCompleted {
                showCompletionSheet = true
            }
        }
        .onChange(of: gameTracker.isCompleted) { completed in
            if completed {
                showCompletionSheet = true
            }
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CompletionView: View {

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
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
        .environmentObject(GameSession())
}
