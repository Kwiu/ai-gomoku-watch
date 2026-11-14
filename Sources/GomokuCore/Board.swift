public enum Stone: Int, Codable, Sendable {
  case black
  case white

  public var opponent: Stone {
    self == .black ? .white : .black
  }
}

public struct BoardPosition: Hashable, Sendable {
  public let row: Int
  public let column: Int

  public init(row: Int, column: Int) {
    self.row = row
    self.column = column
  }
}

public struct GomokuBoard: Sendable {
  public static let directions = [
    (1, 0),
    (0, 1),
    (1, 1),
    (1, -1),
  ]

  public let size: Int
  private var cells: [Stone?]

  public init(size: Int = 11) {
    precondition(size >= 5, "A Gomoku board must be at least 5 x 5.")
    self.size = size
    self.cells = Array(repeating: nil, count: size * size)
  }

  public subscript(_ position: BoardPosition) -> Stone? {
    get {
      guard contains(position) else { return nil }
      return cells[index(for: position)]
    }
    set {
      guard contains(position) else { return }
      cells[index(for: position)] = newValue
    }
  }

  public var isFull: Bool {
    !cells.contains(nil)
  }

  public var stones: [(BoardPosition, Stone)] {
    cells.enumerated().compactMap { index, stone in
      guard let stone else { return nil }
      return (BoardPosition(row: index / size, column: index % size), stone)
    }
  }

  @discardableResult
  public mutating func place(_ stone: Stone, at position: BoardPosition) -> Bool {
    guard contains(position), self[position] == nil else { return false }
    self[position] = stone
    return true
  }

  public func contains(_ position: BoardPosition) -> Bool {
    (0..<size).contains(position.row) && (0..<size).contains(position.column)
  }

  public func winningLine(for stone: Stone) -> [BoardPosition]? {
    for row in 0..<size {
      for column in 0..<size {
        let start = BoardPosition(row: row, column: column)
        guard self[start] == stone else { continue }

        for (rowStep, columnStep) in Self.directions {
          let previous = BoardPosition(
            row: row - rowStep,
            column: column - columnStep
          )
          if contains(previous), self[previous] == stone {
            continue
          }

          var line: [BoardPosition] = []
          var cursor = start
          while contains(cursor), self[cursor] == stone {
            line.append(cursor)
            cursor = BoardPosition(
              row: cursor.row + rowStep,
              column: cursor.column + columnStep
            )
          }

          if line.count >= 5 {
            return Array(line.prefix(5))
          }
        }
      }
    }
    return nil
  }

  public func candidatePositions(near positions: [BoardPosition]) -> [BoardPosition] {
    guard !positions.isEmpty else {
      let center = BoardPosition(row: size / 2, column: size / 2)
      return [center]
    }

    var candidates = Set<BoardPosition>()
    for position in positions {
      for rowOffset in -2...2 {
        for columnOffset in -2...2 {
          let candidate = BoardPosition(
            row: position.row + rowOffset,
            column: position.column + columnOffset
          )
          if contains(candidate), self[candidate] == nil {
            candidates.insert(candidate)
          }
        }
      }
    }
    return candidates.sorted {
      if $0.row == $1.row { return $0.column < $1.column }
      return $0.row < $1.row
    }
  }

  private func index(for position: BoardPosition) -> Int {
    position.row * size + position.column
  }
}
