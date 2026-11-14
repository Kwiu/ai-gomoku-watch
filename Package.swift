// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "AIGomoku",
  platforms: [.watchOS(.v10)],
  products: [
    .library(name: "AIGomoku", targets: ["AIGomoku"]),
    .library(name: "GomokuCore", targets: ["GomokuCore"]),
  ],
  targets: [
    .target(name: "GomokuCore"),
    .target(name: "AIGomoku", dependencies: ["GomokuCore"]),
    .testTarget(name: "GomokuCoreTests", dependencies: ["GomokuCore"]),
  ]
)
