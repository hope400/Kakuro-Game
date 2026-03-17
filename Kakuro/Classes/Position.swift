//
//  Position.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-03-12.
//


struct Position: Hashable, Codable {

    let row: Int
    let col: Int

    var id: String {
        "\(row)-\(col)"
    }
}