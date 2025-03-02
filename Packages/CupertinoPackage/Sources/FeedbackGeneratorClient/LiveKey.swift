import Dependencies
import UIKit

extension FeedbackGeneratorClient: DependencyKey {
  public static let liveValue = {
    let generator = UISelectionFeedbackGenerator()
    let hoge = UIImpactFeedbackGenerator(style: .medium)
    hoge.impactOccurred()
    return Self(
      prepare: { await generator.prepare() },
      mediumImpact: { await hoge.impactOccurred() }
    )
  }()
}
