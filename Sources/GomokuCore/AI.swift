public enum GomokuAI {
  public static func bestMove(on board: GomokuBoard, for stone: Stone) -> BoardPosition? {
    let occupied = board.stones.map(\.0)
    let candidates = board.candidatePositions(near: occupied)
    guard !candidates.isEmpty else { return nil }

    var winningMove: BoardPosition?
    var blockingMove: BoardPosition?

    for candidate in candidates {
      if wouldWin(board: board, position: candidate, stone: stone) {
        winningMove = candidate
        break
      }
      if wouldWin(board: board, position: candidate, stone: stone.opponent) {
        blockingMove = blockingMove ?? candidate
      }
    }

    if let winningMove {
      return winningMove
    }
    if let blockingMove {
      return blockingMove
    }

    let center = Double(board.size - 1) / 2
    return candidates.max { left, right in
      let leftScore = score(board: board, position: left, stone: stone, center: center)
      let rightScore = score(board: board, position: right, stone: stone, center: center)
      if leftScore == rightScore {
        return left.row == right.row
          ? left.column < right.column
          : left.row < right.row
      }
      return leftScore < rightScore
    }
  }

  private static func wouldWin(
    board: GomokuBoard,
    position: BoardPosition,
    stone: Stone
  ) -> Bool {
    var copy = board
    guard copy.place(stone, at: position) else { return false }
    return copy.winningLine(for: stone) != nil
  }

  private static func score(
    board: GomokuBoard,
    position: BoardPosition,
    stone: Stone,
    center: Double
  ) -> Double {
    let offense = patternScore(board: board, position: position, stone: stone)
    let defense = patternScore(board: board, position: position, stone: stone.opponent)
    let distance = abs(Double(position.row) - center) + abs(Double(position.column) - center)
    return offense * 1.08 + defense + max(0, 20 - distance)
  }

  private static func patternScore(
    board: GomokuBoard,
    position: BoardPosition,
    stone: Stone
  ) -> Double {
    var total = 0.0

    for (rowStep, columnStep) in GomokuBoard.directions {
      let forward = run(
        board: board,
        from: position,
        rowStep: rowStep,
        columnStep: columnStep,
        stone: stone
      )
      let backward = run(
        board: board,
        from: position,
        rowStep: -rowStep,
        columnStep: -columnStep,
        stone: stone
      )
      let count = forward.count + backward.count
      let openEnds = (forward.open ? 1 : 0) + (backward.open ? 1 : 0)

      switch (count, openEnds) {
      case (4..., _): total += 10_000_000
      case (3, 2): total += 350_000
      case (3, 1): total += 45_000
      case (2, 2): total += 16_000
      case (2, 1): total += 2_000
      case (1, 2): total += 500
      case (1, 1): total += 80
      default: break
      }
    }

    return total
  }

  private static func run(
    board: GomokuBoard,
    from position: BoardPosition,
    rowStep: Int,
    columnStep: Int,
    stone: Stone
  ) -> (count: Int, open: Bool) {
    var count = 0
    var cursor = BoardPosition(
      row: position.row + rowStep,
      column: position.column + columnStep
    )

    while board.contains(cursor), board[cursor] == stone {
      count += 1
      cursor = BoardPosition(
        row: cursor.row + rowStep,
        column: cursor.column + columnStep
      )
    }

    return (count, board.contains(cursor) && board[cursor] == nil)
  }
}
