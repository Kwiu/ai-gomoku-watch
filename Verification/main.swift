import Foundation

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
  if !condition() {
    fatalError(message)
  }
}

var board = GomokuBoard()
let center = BoardPosition(row: 5, column: 5)
require(board.place(.black, at: center), "Center should be empty.")
require(!board.place(.white, at: center), "Occupied positions must be rejected.")

board = GomokuBoard()
for column in 3...7 {
  board.place(.black, at: BoardPosition(row: 4, column: column))
}
require(board.winningLine(for: .black)?.count == 5, "Five stones in a row must win.")

board = GomokuBoard()
for column in 3...6 {
  board.place(.white, at: BoardPosition(row: 5, column: column))
}
board.place(.black, at: BoardPosition(row: 5, column: 7))
let winningMove = GomokuAI.bestMove(on: board, for: .white)
require(winningMove == BoardPosition(row: 5, column: 2), "AI must take an immediate win.")

board = GomokuBoard()
for column in 3...6 {
  board.place(.black, at: BoardPosition(row: 6, column: column))
}
board.place(.white, at: BoardPosition(row: 4, column: 4))
let blockingMove = GomokuAI.bestMove(on: board, for: .white)
require(
  blockingMove == BoardPosition(row: 6, column: 2)
    || blockingMove == BoardPosition(row: 6, column: 7),
  "AI must block an immediate loss."
)

let openingMove = GomokuAI.bestMove(on: GomokuBoard(), for: .white)
require(openingMove == BoardPosition(row: 5, column: 5), "AI should open in the center.")

print("Gomoku core verification passed")
