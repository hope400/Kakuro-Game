//
//  CellType.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-03-14.
//


enum CellType: Codable {
    case block(horizontalSum: Int?, verticalSum: Int?)
    case playable
}