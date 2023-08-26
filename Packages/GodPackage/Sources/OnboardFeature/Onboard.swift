import ComposableArchitecture
import GenderSettingFeature
import HowItWorksFeature
import SwiftUI

public struct OnboardReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var welcome = WelcomeReducer.State()
    var path = StackState<Path.State>()
    public init() {}
  }

  public enum Action: Equatable {
    case welcome(WelcomeReducer.Action)
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.welcome, action: /Action.welcome) {
      WelcomeReducer()
    }
    Reduce { state, action in
      switch action {
      case .welcome(.getStartedButtonTapped):
        state.path.append(.gradeSetting())
        return .none

      case .welcome:
        return .none

      case let .path(.element(_, action)):
        switch action {
        case .gradeSetting(.delegate(.nextScreen)):
          state.path.append(.schoolSetting())

        case .schoolSetting(.delegate(.nextScreen)):
          state.path.append(.phoneNumber())

        case let .phoneNumber(.delegate(.nextScreen(verifyID))):
          state.path.append(.oneTimeCode(.init(verifyID: verifyID)))

        case .oneTimeCode(.delegate(.nextScreen)):
          state.path.append(.firstNameSetting())

        case .firstNameSetting(.delegate(.nextScreen)):
          state.path.append(.lastNameSetting())

        case .lastNameSetting(.delegate(.nextScreen)):
          state.path.append(.usernameSetting())

        case .usernameSetting(.delegate(.nextScreen)):
          state.path.append(.genderSetting())

        case .genderSetting(.delegate(.nextScreen)):
          state.path.append(.profilePhotoSetting())

        case .profilePhotoSetting(.delegate(.nextScreen)):
          state.path.append(.addFriends())

        case .addFriends(.delegate(.nextScreen)):
          state.path.append(.howItWorks())
        default:
          print(action)
        }
        return .none

      case .path:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }

  public struct Path: Reducer {
    public enum State: Equatable {
      case gradeSetting(GradeSettingReducer.State = .init())
      case schoolSetting(SchoolSettingReducer.State = .init())
      case findFriend(FindFriendReducer.State = .init())
      case phoneNumber(PhoneNumberReducer.State = .init())
      case oneTimeCode(OneTimeCodeReducer.State)
      case firstNameSetting(FirstNameSettingReducer.State = .init())
      case lastNameSetting(LastNameSettingReducer.State = .init())
      case usernameSetting(UsernameSettingReducer.State = .init())
      case genderSetting(GenderSettingReducer.State = .init())
      case profilePhotoSetting(ProfilePhotoSettingReducer.State = .init())
      case addFriends(AddFriendsReducer.State = .init())
      case howItWorks(HowItWorksReducer.State = .init())
    }

    public enum Action: Equatable {
      case gradeSetting(GradeSettingReducer.Action)
      case schoolSetting(SchoolSettingReducer.Action)
      case findFriend(FindFriendReducer.Action)
      case phoneNumber(PhoneNumberReducer.Action)
      case oneTimeCode(OneTimeCodeReducer.Action)
      case firstNameSetting(FirstNameSettingReducer.Action)
      case lastNameSetting(LastNameSettingReducer.Action)
      case usernameSetting(UsernameSettingReducer.Action)
      case genderSetting(GenderSettingReducer.Action)
      case profilePhotoSetting(ProfilePhotoSettingReducer.Action)
      case addFriends(AddFriendsReducer.Action)
      case howItWorks(HowItWorksReducer.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.gradeSetting, action: /Action.gradeSetting, child: GradeSettingReducer.init)
      Scope(state: /State.schoolSetting, action: /Action.schoolSetting, child: SchoolSettingReducer.init)
      Scope(state: /State.findFriend, action: /Action.findFriend, child: FindFriendReducer.init)
      Scope(state: /State.phoneNumber, action: /Action.phoneNumber, child: PhoneNumberReducer.init)
      Scope(state: /State.oneTimeCode, action: /Action.oneTimeCode, child: OneTimeCodeReducer.init)
      Scope(state: /State.firstNameSetting, action: /Action.firstNameSetting, child: FirstNameSettingReducer.init)
      Scope(state: /State.lastNameSetting, action: /Action.lastNameSetting, child: LastNameSettingReducer.init)
      Scope(state: /State.usernameSetting, action: /Action.usernameSetting, child: UsernameSettingReducer.init)
      Scope(state: /State.genderSetting, action: /Action.genderSetting, child: GenderSettingReducer.init)
      Scope(state: /State.profilePhotoSetting, action: /Action.profilePhotoSetting, child: ProfilePhotoSettingReducer.init)
      Scope(state: /State.addFriends, action: /Action.addFriends, child: AddFriendsReducer.init)
      Scope(state: /State.howItWorks, action: /Action.howItWorks, child: HowItWorksReducer.init)
    }
  }
}

public struct OnboardView: View {
  let store: StoreOf<OnboardReducer>

  public init(store: StoreOf<OnboardReducer>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
      WelcomeView(store: store.scope(state: \.welcome, action: OnboardReducer.Action.welcome))
    } destination: { store in
      switch store {
      case .gradeSetting:
        CaseLet(
          /OnboardReducer.Path.State.gradeSetting,
          action: OnboardReducer.Path.Action.gradeSetting,
          then: GradeSettingView.init(store:)
        )
      case .schoolSetting:
        CaseLet(
          /OnboardReducer.Path.State.schoolSetting,
          action: OnboardReducer.Path.Action.schoolSetting,
          then: SchoolSettingView.init(store:)
        )
      case .findFriend:
        CaseLet(
          /OnboardReducer.Path.State.findFriend,
          action: OnboardReducer.Path.Action.findFriend,
          then: FindFriendView.init(store:)
        )
      case .phoneNumber:
        CaseLet(
          /OnboardReducer.Path.State.phoneNumber,
          action: OnboardReducer.Path.Action.phoneNumber,
          then: PhoneNumberView.init(store:)
        )
      case .oneTimeCode:
        CaseLet(
          /OnboardReducer.Path.State.oneTimeCode,
          action: OnboardReducer.Path.Action.oneTimeCode,
          then: OneTimeCodeView.init(store:)
        )
      case .firstNameSetting:
        CaseLet(
          /OnboardReducer.Path.State.firstNameSetting,
          action: OnboardReducer.Path.Action.firstNameSetting,
          then: FirstNameSettingView.init(store:)
        )
      case .lastNameSetting:
        CaseLet(
          /OnboardReducer.Path.State.lastNameSetting,
          action: OnboardReducer.Path.Action.lastNameSetting,
          then: LastNameSettingView.init(store:)
        )
      case .usernameSetting:
        CaseLet(
          /OnboardReducer.Path.State.usernameSetting,
          action: OnboardReducer.Path.Action.usernameSetting,
          then: UsernameSettingView.init(store:)
        )
      case .genderSetting:
        CaseLet(
          /OnboardReducer.Path.State.genderSetting,
          action: OnboardReducer.Path.Action.genderSetting,
          then: GenderSettingView.init(store:)
        )
      case .profilePhotoSetting:
        CaseLet(
          /OnboardReducer.Path.State.profilePhotoSetting,
          action: OnboardReducer.Path.Action.profilePhotoSetting,
          then: ProfilePhotoSettingView.init(store:)
        )
      case .addFriends:
        CaseLet(
          /OnboardReducer.Path.State.addFriends,
          action: OnboardReducer.Path.Action.addFriends,
          then: AddFriendsView.init(store:)
        )
      case .howItWorks:
        CaseLet(
          /OnboardReducer.Path.State.howItWorks,
          action: OnboardReducer.Path.Action.howItWorks,
          then: HowItWorksView.init(store:)
        )
      }
    }
    .tint(Color.white)
  }
}
