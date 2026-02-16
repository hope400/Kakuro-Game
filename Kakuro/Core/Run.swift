//
//  Run.swift
//  Kakuro
//
//  Created by Shaquille O Neil on 2026-02-05.
//

import Foundation

enum RunDirection {
    case horizontal
    case vertical
}

struct Run: Identifiable {
    let id = UUID()
    let direction: RunDirection
    let positions: [Position]
    var sum: Int?
}
