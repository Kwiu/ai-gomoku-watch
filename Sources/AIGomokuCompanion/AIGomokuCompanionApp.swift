import SwiftUI

@main
struct AIGomokuCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 18) {
                Image(systemName: "circle.grid.3x3.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.orange)
                Text("AI 五子棋")
                    .font(.largeTitle.bold())
                Text("请在 Apple Watch 上打开游戏")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
