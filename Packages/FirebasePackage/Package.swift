// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FirebasePackage",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(name: "AnalyticsClient", targets: ["AnalyticsClient"]),
    .library(name: "ServerConfig", targets: ["ServerConfig"]),
    .library(name: "ServerConfigClient", targets: ["ServerConfigClient"]),
    .library(name: "FirebaseCoreClient", targets: ["FirebaseCoreClient"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.5.1"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.8.0"),
  ],
  targets: [
    .target(
      name: "AnalyticsClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
      ]
    ),
    .target(
      name: "ServerConfig"
    ),
    .target(
      name: "ServerConfigClient",
      dependencies: [
        "ServerConfig",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "FirebaseCoreClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
      ]
    ),
  ]
)
