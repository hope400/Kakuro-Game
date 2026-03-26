//
//  statistics.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-03-05.
//

import Foundation



struct Statistics: Codable, Identifiable {

    var id: UUID
    var totalGames: Int
    var totalWins: Int
    var totalLosses: Int
    var bestTime: Double?
    var averageTime: Double?
    var difficulty: GameDifficulty?
    var totalIncompleteGames: Int
    var totalMoves: Int

    init(
        id: UUID = UUID(),
        totalGames: Int = 0,
        totalWins: Int = 0,
        totalLosses: Int = 0,
        bestTime: Double? = nil,
        averageTime: Double? = nil,
        difficulty: GameDifficulty? = nil,
        totalIncompleteGames: Int = 0,
        totalMoves: Int = 0
    )
    {
        self.id = id
        self.totalGames = totalGames
        self.totalWins = totalWins
        self.totalLosses = totalLosses
        self.bestTime = bestTime
        self.averageTime = averageTime
        self.difficulty = difficulty
        self.totalIncompleteGames = totalIncompleteGames
        self.totalMoves = totalMoves
    }

    mutating func recordWin(time: Double, moves: Int) {
        totalGames += 1
        totalWins += 1
        totalMoves += moves

        if let best = bestTime {
            bestTime = min(best, time)
        } else {
            bestTime = time
        }

        if let avg = averageTime {
            let winsBefore = totalWins - 1
            averageTime = ((avg * Double(winsBefore)) + time) / Double(totalWins)
        } else {
            averageTime = time
        }
    }


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    mutating func recordLoss(moves: Int) {
        totalGames += 1
        totalLosses += 1
        totalMoves += moves
    }

    mutating func recordIncomplete() {
        totalIncompleteGames += 1
    }
}
