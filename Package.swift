// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GamesApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GamesApp",
            targets: ["GamesApp"])
    ],
    targets: [
        .target(
            name: "GamesApp",
            path: "TicTacToe",
            exclude: [
                "TicTacToeApp.swift",
                "Assets.xcassets"
            ]
        )
    ]
)
