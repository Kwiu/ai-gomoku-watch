import Combine
import GomokuCore
import WatchKit

@MainActor
final class GomokuGame: ObservableObject {
  static let boardSize = 11

  @Published private(set) var board = GomokuBoard(size: boardSize)
  @Published private(set) var lastMove: BoardPosition?
  @Published private(set) var winningLine: [BoardPosition] = []
  @Published private(set) var winner: Stone?
  @Published private(set) var isAIThinking = false
  @Published private(set) var message = "轮到你落子"

  private var aiTask: Task<Void, Never>?

  func playHuman(at position: BoardPosition) {
    guard !isAIThinking, winner == nil, board[position] == nil else { return }
    guard board.place(.black, at: position) else { return }

    lastMove = position
    WKInterfaceDevice.current().play(.click)
    finishTurn(for: .black, playerMessage: "你赢了")

    guard winner == nil, !board.isFull else { return }
    isAIThinking = true
    message = "AI 正在思考"

    aiTask = Task { [weak self] in
      try? await Task.sleep(nanoseconds: 280_000_000)
      guard !Task.isCancelled else { return }
      self?.playAI()
    }
  }

  func restart() {
    aiTask?.cancel()
    board = GomokuBoard(size: Self.boardSize)
    lastMove = nil
    winningLine = []
    winner = nil
    isAIThinking = false
    message = "轮到你落子"
    WKInterfaceDevice.current().play(.start)
  }

  private func playAI() {
    defer { aiTask = nil }

    guard winner == nil,
      let move = GomokuAI.bestMove(on: board, for: .white),
      board.place(.white, at: move)
    else {
      isAIThinking = false
      message = board.isFull ? "平局" : "AI 无法落子"
      return
    }

    lastMove = move
    isAIThinking = false
    finishTurn(for: .white, playerMessage: "AI 赢了")

    if winner == nil, !board.isFull {
      message = "轮到你落子"
    }
  }

  private func finishTurn(for stone: Stone, playerMessage: String) {
    if let line = board.winningLine(for: stone) {
      winner = stone
      winningLine = line
      message = playerMessage
      WKInterfaceDevice.current().play(.success)
    } else if board.isFull {
      message = "平局"
      WKInterfaceDevice.current().play(.failure)
    }
  }
}
