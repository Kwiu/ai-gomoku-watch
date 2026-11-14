import Testing

@testable import GomokuCore

struct GomokuCoreTests {
  @Test
  func rejectsOccupiedPosition() {
    var board = GomokuBoard()
    let move = BoardPosition(row: 5, column: 5)

    #expect(board.place(.black, at: move))
    #expect(!board.place(.white, at: move))
  }

  @Test
  func detectsFiveInARow() {
    var board = GomokuBoard()
    for column in 3...7 {
      board.place(.black, at: BoardPosition(row: 4, column: column))
    }

    #expect(board.winningLine(for: .black)?.count == 5)
  }

  @Test
  func aiTakesImmediateWin() {
    var board = GomokuBoard()
    for column in 3...6 {
      board.place(.white, at: BoardPosition(row: 5, column: column))
    }
    board.place(.black, at: BoardPosition(row: 5, column: 7))

    let move = GomokuAI.bestMove(on: board, for: .white)

    #expect(move == BoardPosition(row: 5, column: 2))
  }

  @Test
  func aiBlocksImmediateThreat() {
    var board = GomokuBoard()
    for column in 3...6 {
      board.place(.black, at: BoardPosition(row: 6, column: column))
    }
    board.place(.white, at: BoardPosition(row: 4, column: 4))

    let move = GomokuAI.bestMove(on: board, for: .white)

    #expect(
      move == BoardPosition(row: 6, column: 2)
        || move == BoardPosition(row: 6, column: 7))
  }
}
