//
//  MyStats.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-01-29.
//

import SwiftUI
import FirebaseAuth

struct MyStats: View {

    @EnvironmentObject var gameTracker: GameSession
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var selectedDifficulty: GameDifficulty = .easy

    var filteredStats: Statistics {
        gameTracker.filterStatistics(for: selectedDifficulty)
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                header
                difficultyChips
                performanceOverview
                timePerformance
                gameplayMetrics
            }
            .padding()
            .onAppear {
                loadStats()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    func loadStats() {

        let manager = firebaseManager

        Task {

            var stats = Statistics()

            if !gameTracker.isGuestMode {
                if let loadedStats = try? await manager.loadStatistics(for: selectedDifficulty) {
                    stats = loadedStats
                }
            }
            await MainActor.run {
                gameTracker.statistics = stats
            }
        }
    }
}


// MARK: - Header

extension MyStats {

    var playerName: String {

        if let name = firebaseManager.user?.displayName,
           !name.isEmpty {
            return name
        }

        if let email = firebaseManager.user?.email {
            return email.components(separatedBy: "@").first ?? "Player"
        }

        return "Player"
    }

    var header: some View {

        VStack(spacing: 4) {

            Text(playerName)
                .font(.title2)
                .fontWeight(.semibold)

            Text("KAKURO STATISTICS")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


// MARK: - Difficulty Chips

extension MyStats {

    var difficultyChips: some View {

        HStack(spacing: 12) {
            chip(.easy)
            chip(.medium)
            chip(.hard)
        }
    }

    func chip(_ difficulty: GameDifficulty) -> some View {

        Button {

            selectedDifficulty = difficulty
            loadStats()   // reload stats for the new difficulty

        } label: {

            Text(difficulty.rawValue.capitalized)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedDifficulty == difficulty
                    ? Color.blue
                    : Color(.systemGray5)
                )
                .foregroundColor(
                    selectedDifficulty == difficulty
                    ? .white
                    : .primary
                )
                .clipShape(Capsule())
        }
    }
}


// MARK: - Performance Overview

extension MyStats {

    var performanceOverview: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label("Performance Overview", systemImage: "chart.bar")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {

                statBox("TOTAL PLAYED",
                        "\(filteredStats.totalGames)",
                        .blue)

                statBox("TOTAL WINS",
                        "\(filteredStats.totalWins)",
                        .green)

                statBox("TOTAL LOSSES",
                        "\(filteredStats.totalLosses)",
                        .red)

                statBox("INCOMPLETE",
                        "\(filteredStats.totalIncompleteGames)",
                        .gray)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


// MARK: - Time Performance

extension MyStats {

    var timePerformance: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label("Time Performance", systemImage: "clock")

            HStack {

                VStack(alignment: .leading) {

                    Text("Best Time")
                        .foregroundStyle(.secondary)

                    Text(formatTime(filteredStats.bestTime ?? 0))
                        .foregroundColor(.orange)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {

                    Text("Average Time")
                        .foregroundStyle(.secondary)

                    Text(formatTime(filteredStats.averageTime ?? 0))
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


// MARK: - Gameplay Metrics

extension MyStats {

    var gameplayMetrics: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label("Gameplay Metrics", systemImage: "sparkles")

            HStack {

                VStack(alignment: .leading) {

                    Text("WIN RATE")
                        .foregroundStyle(.secondary)

                    Text("\(winRate)%")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .trailing) {

                    Text("AVG MOVES")
                        .foregroundStyle(.secondary)

                    Text("\(averageMoves)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


// MARK: - Helpers

extension MyStats {

    func statBox(_ title: String, _ value: String, _ color: Color) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func formatTime(_ time: Double) -> String {

        let minutes = Int(time) / 60
        let seconds = Int(time) % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

    var winRate: Int {

        guard filteredStats.totalGames > 0 else { return 0 }

        return Int(
            Double(filteredStats.totalWins)
            / Double(filteredStats.totalGames)
            * 100
        )
    }

    var averageMoves: Int {

        guard filteredStats.totalGames > 0 else { return 0 }

        return filteredStats.totalMoves /
               filteredStats.totalGames
    }
}


#Preview {
    MyStats()
        .environmentObject(GameSession())
        .environmentObject(FirebaseManager.shared)
}
