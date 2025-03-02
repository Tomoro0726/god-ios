import AnalyticsClient
import ComposableArchitecture
import FirebaseAuthClient
import FirebaseCoreClient
import FirebaseMessagingClient
import God
import GodClient
import UIKit
import UserDefaultsClient
import UserNotificationClient

public struct AppDelegateLogic: Reducer {
  public struct State: Equatable {}
  public enum Action: Equatable {
    case didFinishLaunching
    case didReceiveRemoteNotification([AnyHashable: Any])
    case didRegisterForRemoteNotifications(TaskResult<Data>)
    case userNotifications(UserNotificationClient.DelegateEvent)
    case messaging(FirebaseMessagingClient.DelegateAction)
    case configurationForConnecting(UIApplicationShortcutItem?)
    case dynamicLink(URL?)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case didFinishLaunching
    }

    public static func == (lhs: AppDelegateLogic.Action, rhs: AppDelegateLogic.Action) -> Bool {
      switch (lhs, rhs) {
      case (.didReceiveRemoteNotification, .didReceiveRemoteNotification):
        return false
      default:
        return lhs == rhs
      }
    }
  }

  @Dependency(\.analytics) var analytics
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.firebaseCore) var firebaseCore
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.userNotifications) var userNotifications
  @Dependency(\.application.registerForRemoteNotifications) var registerForRemoteNotifications
  @Dependency(\.godClient.createFirebaseRegistrationToken) var createFirebaseRegistrationToken
  @Dependency(\.firebaseMessaging) var firebaseMessaging

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .run { @MainActor send in
        firebaseCore.configure()
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            guard try await userNotifications.requestAuthorization([.alert, .sound, .badge])
            else { return }
            await registerForRemoteNotifications()
          }
          group.addTask {
            for await event in userNotifications.delegate() {
              await send(.userNotifications(event))
            }
          }
          group.addTask {
            for await event in firebaseMessaging.delegate() {
              await send(.messaging(event))
            }
          }
          group.addTask {
            await send(.delegate(.didFinishLaunching))
          }
        }
      }
    case let .didReceiveRemoteNotification(userInfo):
      guard let badge = userInfo["badge"] as? String else { return .none }
      guard let badgeCount = Int(badge) else { return .none }
      return .run { _ in
        try? await userNotifications.setBadgeCount(badgeCount)
      }
    case .didRegisterForRemoteNotifications(.failure):
      return .none

    case let .didRegisterForRemoteNotifications(.success(tokenData)):
      return .run { _ in
        #if DEBUG
          firebaseAuth.setAPNSToken(tokenData, .sandbox)
        #else
          firebaseAuth.setAPNSToken(tokenData, .prod)
        #endif
        firebaseMessaging.setAPNSToken(tokenData)
        await createFirebaseRegistrationTokenRequest()
      }

    case let .userNotifications(.willPresentNotification(notification, completionHandler)):
      return .run { _ in
        _ = firebaseMessaging.appDidReceiveMessage(notification.request)
        completionHandler([.list, .sound, .badge, .banner])
      }

    case let .userNotifications(.didReceiveResponse(response, completionHandler)):
      return .run { _ in
        _ = firebaseMessaging.appDidReceiveMessage(response.notification.request)
        completionHandler()
      }

    case .messaging(.didReceiveRegistrationToken):
      return .run { _ in
        await createFirebaseRegistrationTokenRequest()
      }

    case let .dynamicLink(.some(url)):
      analytics.logEvent("event_invitation", [
        "deepLink": url.absoluteString,
      ])
      return .run { _ in
        await userDefaults.setDynamicLinkURL(url.absoluteString)
      }

    default:
      return .none
    }
  }

  func createFirebaseRegistrationTokenRequest() async {
    do {
      let token = try await firebaseMessaging.token()
      let input = God.CreateFirebaseRegistrationTokenInput(token: token)
      _ = try await createFirebaseRegistrationToken(input)
    } catch {
      print("createFirebaseRegistrationTokenRequest: \(error)")
    }
  }
}
