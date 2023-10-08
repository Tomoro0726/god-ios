// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GodPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v16),
  ],
  products: [
    .library(name: "AboutFeature", targets: ["AboutFeature"]),
    .library(name: "ActivityFeature", targets: ["ActivityFeature"]),
    .library(name: "AddFeature", targets: ["AddFeature"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "CashOutFeature", targets: ["CashOutFeature"]),
    .library(name: "CupertinoMessageFeature", targets: ["CupertinoMessageFeature"]),
    .library(name: "ForceUpdateFeature", targets: ["ForceUpdateFeature"]),
    .library(name: "GodFeature", targets: ["GodFeature"]),
    .library(name: "GodModeFeature", targets: ["GodModeFeature"]),
    .library(name: "HowItWorksFeature", targets: ["HowItWorksFeature"]),
    .library(name: "InboxFeature", targets: ["InboxFeature"]),
    .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
    .library(name: "MaintenanceFeature", targets: ["MaintenanceFeature"]),
    .library(name: "ManageAccountFeature", targets: ["ManageAccountFeature"]),
    .library(name: "NavigationFeature", targets: ["NavigationFeature"]),
    .library(name: "OnboardFeature", targets: ["OnboardFeature"]),
    .library(name: "PlayAgainFeature", targets: ["PlayAgainFeature"]),
    .library(name: "PollFeature", targets: ["PollFeature"]),
    .library(name: "ProfileEditFeature", targets: ["ProfileEditFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileShareFeature", targets: ["ProfileShareFeature"]),
    .library(name: "RevealFeature", targets: ["RevealFeature"]),
    .library(name: "ShareScreenshotFeature", targets: ["ShareScreenshotFeature"]),
    .library(name: "ShopFeature", targets: ["ShopFeature"]),
  ],
  dependencies: [
    .package(path: "../CupertinoPackage"),
    .package(path: "../UIComponentPackage"),
    .package(path: "../DependencyPackage"),
    .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
    .package(url: "https://github.com/edonv/SwiftUIMessage", from: "0.0.3"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
    .package(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", from: "2.1.1"),
  ],
  targets: [
    .target(name: "AboutFeature", dependencies: [
      "HowItWorksFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "SwiftUIMessage", package: "SwiftUIMessage"),
      .product(name: "GodActionSheet", package: "UIComponentPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
    ]),
    .target(name: "ActivityFeature", dependencies: [
      "ProfileFeature",
    ]),
    .target(name: "AddFeature", dependencies: [
      "ProfileFeature",
      "CupertinoMessageFeature",
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "SearchField", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "AppFeature", dependencies: [
      "LaunchFeature",
      "OnboardFeature",
      "NavigationFeature",
      "ForceUpdateFeature",
      "MaintenanceFeature",
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "TcaHelpers", package: "DependencyPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "FirestoreClient", package: "DependencyPackage"),
      .product(name: "FirebaseCoreClient", package: "DependencyPackage"),
      .product(name: "FirebaseMessagingClient", package: "DependencyPackage"),
    ]),
    .target(name: "CashOutFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-ios"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ], resources: [.copy("Coin.json")]),
    .target(name: "CupertinoMessageFeature", dependencies: [
      .product(name: "SwiftUIMessage", package: "SwiftUIMessage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ForceUpdateFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "GodFeature", dependencies: [
      "PollFeature",
      "CashOutFeature",
      "PlayAgainFeature",
    ], resources: [.copy("Loading.json")]),
    .target(name: "GodModeFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "StoreKitHelpers", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "HowItWorksFeature", dependencies: [
      .product(name: "Lottie", package: "lottie-ios"),
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ], resources: [.copy("Onboarding.json")]),
    .target(name: "InboxFeature", dependencies: [
      "RevealFeature",
      "GodModeFeature",
      "ShareScreenshotFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "UserNotificationClient", package: "CupertinoPackage"),
      .product(name: "NotificationCenterClient", package: "CupertinoPackage"),
      .product(name: "AnimationDisableTransaction", package: "UIComponentPackage"),
    ]),
    .target(name: "LaunchFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "MaintenanceFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ManageAccountFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "NavigationFeature", dependencies: [
      "AboutFeature",
      "ActivityFeature",
      "AddFeature",
      "GodFeature",
      "InboxFeature",
    ]),
    .target(name: "OnboardFeature", dependencies: [
      "HowItWorksFeature",
      "CupertinoMessageFeature",
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "PhotosClient", package: "CupertinoPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "StringHelpers", package: "DependencyPackage"),
      .product(name: "ContactsClient", package: "CupertinoPackage"),
      .product(name: "RoundedCorner", package: "UIComponentPackage"),
      .product(name: "AnalyticsClient", package: "DependencyPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
      .product(name: "FirebaseStorageClient", package: "DependencyPackage"),
      .product(name: "PhoneNumberDependencies", package: "DependencyPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
      .product(name: "FirebaseDynamicLinkClient", package: "DependencyPackage"),
    ], resources: [.copy("onboarding.json")]),
    .target(name: "PlayAgainFeature", dependencies: [
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "PollFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "LabeledButton", package: "UIComponentPackage"),
      .product(name: "FeedbackGeneratorClient", package: "CupertinoPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ProfileEditFeature", dependencies: [
      "ManageAccountFeature",
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "UserDefaultsClient", package: "CupertinoPackage"),
      .product(name: "FirebaseAuthClient", package: "DependencyPackage"),
      .product(name: "FirebaseStorageClient", package: "DependencyPackage"),
    ]),
    .target(name: "ProfileFeature", dependencies: [
      "ShopFeature",
      "ProfileEditFeature",
      "ProfileShareFeature",
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "CachedAsyncImage", package: "swiftui-cached-async-image"),
    ]),
    .target(name: "ProfileShareFeature", dependencies: [
      "CupertinoMessageFeature",
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "Constants", package: "DependencyPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "UIPasteboardClient", package: "CupertinoPackage"),
      .product(name: "UIApplicationClient", package: "CupertinoPackage"),
      .product(name: "BackgroundClearSheet", package: "UIComponentPackage"),
      .product(name: "AnimationDisableTransaction", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "RevealFeature", dependencies: [
      .product(name: "Build", package: "CupertinoPackage"),
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "StoreKitClient", package: "CupertinoPackage"),
      .product(name: "StoreKitHelpers", package: "DependencyPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShareScreenshotFeature", dependencies: [
      .product(name: "AsyncValue", package: "DependencyPackage"),
      .product(name: "PhotosClient", package: "CupertinoPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
    .target(name: "ShopFeature", dependencies: [
      .product(name: "Colors", package: "UIComponentPackage"),
      .product(name: "GodClient", package: "DependencyPackage"),
      .product(name: "SearchField", package: "UIComponentPackage"),
      .product(name: "ButtonStyles", package: "UIComponentPackage"),
      .product(name: "ProfileImage", package: "UIComponentPackage"),
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
    ]),
  ]
)
