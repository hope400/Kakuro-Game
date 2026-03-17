struct Cell: Identifiable, Codable {

    let position: Position
    var type: CellType
    var value: Int?

    var id: String {
        position.id
    }

}

extension Cell {

    var isPlayable: Bool {
        if case .playable = type { return true }
        return false
    }

    var isBlock: Bool {
        if case .block = type { return true }
        return false
    }

    var horizontalSum: Int? {
        if case .block(let h, _) = type { return h }
        return nil
    }

    var verticalSum: Int? {
        if case .block(_, let v) = type { return v }
        return nil
    }

}
