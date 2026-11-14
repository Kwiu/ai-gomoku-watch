import GomokuCore
import SwiftUI

@MainActor
struct GameView: View {
  @StateObject private var game = GomokuGame()

  var body: some View {
    GeometryReader { proxy in
      let boardSide = min(proxy.size.width - 12, proxy.size.height - 72)

      VStack(spacing: 5) {
        statusBar
        boardView(side: boardSide)
        controls
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal, 6)
    }
    .background(
      LinearGradient(
        colors: [Color(red: 0.07, green: 0.08, blue: 0.10), .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
  }

  private var statusBar: some View {
    HStack(spacing: 5) {
      Circle()
        .fill(game.winner == .white ? Color.white : Color.black)
        .overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 1))
        .frame(width: 10, height: 10)
      Text(game.message)
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
      Spacer(minLength: 0)
      Text("AI")
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(Color.orange)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.orange.opacity(0.16), in: Capsule())
    }
  }

  private func boardView(side: CGFloat) -> some View {
    GomokuBoardView(
      board: game.board,
      lastMove: game.lastMove,
      winningLine: game.winningLine,
      onTap: game.playHuman
    )
    .frame(width: side, height: side)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(Color(red: 0.72, green: 0.52, blue: 0.30))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .stroke(.white.opacity(0.16), lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }

  private var controls: some View {
    HStack(spacing: 8) {
      Label(game.isAIThinking ? "思考中" : "你执黑", systemImage: "circle.fill")
        .font(.system(size: 11, weight: .medium, design: .rounded))
        .foregroundStyle(.white.opacity(0.78))
        .labelStyle(.titleAndIcon)

      Spacer(minLength: 0)

      Button(action: game.restart) {
        Image(systemName: "arrow.counterclockwise")
          .font(.system(size: 14, weight: .bold))
          .frame(width: 34, height: 28)
      }
      .buttonStyle(.borderedProminent)
      .tint(.orange)
      .accessibilityLabel("重新开始")
    }
  }
}

private struct GomokuBoardView: View {
  private let inset: CGFloat = 8

  let board: GomokuBoard
  let lastMove: BoardPosition?
  let winningLine: [BoardPosition]
  let onTap: (BoardPosition) -> Void

  var body: some View {
    GeometryReader { proxy in
      Canvas { context, size in
        let step = gridStep(in: size)
        let boardLength = step * CGFloat(board.size - 1)
        let origin = CGPoint(
          x: (size.width - boardLength) / 2,
          y: (size.height - boardLength) / 2
        )

        var grid = Path()
        for index in 0..<board.size {
          let offset = CGFloat(index) * step
          grid.move(to: CGPoint(x: origin.x + offset, y: origin.y))
          grid.addLine(to: CGPoint(x: origin.x + offset, y: origin.y + boardLength))
          grid.move(to: CGPoint(x: origin.x, y: origin.y + offset))
          grid.addLine(to: CGPoint(x: origin.x + boardLength, y: origin.y + offset))
        }
        context.stroke(grid, with: .color(.black.opacity(0.55)), lineWidth: 0.7)

        for (position, stone) in board.stones {
          let center = point(for: position, size: size)
          let radius = max(3.5, step * 0.39)
          let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
          )
          let isWinning = winningLine.contains(position)
          let fill: Color = stone == .black ? .black : .white
          context.fill(Path(ellipseIn: rect), with: .color(fill))
          context.stroke(
            Path(ellipseIn: rect),
            with: .color(isWinning ? Color.orange : fill.opacity(0.42)),
            lineWidth: isWinning ? 2 : 0.8
          )
        }

        if let lastMove {
          let center = point(for: lastMove, size: size)
          let marker = CGRect(
            x: center.x - 2,
            y: center.y - 2,
            width: 4,
            height: 4
          )
          context.fill(Path(ellipseIn: marker), with: .color(.orange))
        }
      }
      .contentShape(Rectangle())
      .gesture(
        SpatialTapGesture()
          .onEnded { value in
            guard
              let position = boardPosition(
                at: value.location,
                canvasSize: proxy.size
              )
            else { return }
            onTap(position)
          }
      )
      .accessibilityLabel("AI 五子棋棋盘")
      .accessibilityHint("轻点交叉点落下一枚黑子")
    }
  }

  private func gridStep(in size: CGSize) -> CGFloat {
    (min(size.width, size.height) - inset * 2) / CGFloat(board.size - 1)
  }

  private func point(for position: BoardPosition, size: CGSize) -> CGPoint {
    let step = gridStep(in: size)
    let boardLength = step * CGFloat(board.size - 1)
    return CGPoint(
      x: (size.width - boardLength) / 2 + CGFloat(position.column) * step,
      y: (size.height - boardLength) / 2 + CGFloat(position.row) * step
    )
  }

  private func boardPosition(at location: CGPoint, canvasSize: CGSize) -> BoardPosition? {
    let step = gridStep(in: canvasSize)
    let boardLength = step * CGFloat(board.size - 1)
    let origin = CGPoint(
      x: (canvasSize.width - boardLength) / 2,
      y: (canvasSize.height - boardLength) / 2
    )
    let column = Int(((location.x - origin.x) / step).rounded())
    let row = Int(((location.y - origin.y) / step).rounded())
    let position = BoardPosition(row: row, column: column)
    return board.contains(position) ? position : nil
  }
}
