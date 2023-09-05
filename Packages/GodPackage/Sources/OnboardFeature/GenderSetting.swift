import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct GenderSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var help: GenderHelpLogic.State?
    public init() {}
  }

  public enum Action: Equatable {
    case infoButtonTapped
    case genderButtonTapped(God.Gender)
    case updateUserProfileResponse(TaskResult<God.UpdateUserProfileMutation.Data>)
    case help(PresentationAction<GenderHelpLogic.Action>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen
    }
  }
  
  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .infoButtonTapped:
        state.help = .init()
        return .none

      case let .genderButtonTapped(gender):
        let input = God.UpdateUserProfileInput(gender: .init(gender))
        return .run { send in
          await send(
            .updateUserProfileResponse(
              TaskResult {
                try await godClient.updateUserProfile(input)
              }
            )
          )
        }
      case .updateUserProfileResponse(.success):
        return .send(.delegate(.nextScreen))

      case let .updateUserProfileResponse(.failure(error)):
        print(error)
        return .none

      case .help(.dismiss):
        state.help = nil
        return .none
        
      case .help:
        return .none

      case .delegate:
        return .none
      }
    }
    .ifLet(\.$help, action: /Action.help) {
      GenderHelpLogic()
    }
  }
}

public struct GenderSettingView: View {
  let store: StoreOf<GenderSettingLogic>

  public init(store: StoreOf<GenderSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.godService
          .ignoresSafeArea()

        VStack(spacing: 24) {
          Text("What's your gender?")
            .bold()
            .foregroundColor(Color.white)

          HStack(spacing: 24) {
            GenderChoiceView(gender: .male) {
              viewStore.send(.genderButtonTapped(.male))
            }
            GenderChoiceView(gender: .female) {
              viewStore.send(.genderButtonTapped(.female))
            }
          }
          HStack(spacing: 24) {
            GenderChoiceView(gender: .other) {
              viewStore.send(.genderButtonTapped(.other))
            }
          }
        }
      }
      .toolbar {
        Button {
          viewStore.send(.infoButtonTapped)
        } label: {
          Image(systemName: "info.circle.fill")
            .foregroundColor(.white)
        }
      }
      .sheet(
        store: store.scope(
          state: \.$help,
          action: GenderSettingLogic.Action.help
        )
      ) { store in
        GenderHelpView(store: store)
          .presentationDetents([.fraction(0.4)])
          .presentationDragIndicator(.visible)
      }
    }
  }
}

struct GenderSettingViewPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      GenderSettingView(
        store: .init(
          initialState: GenderSettingLogic.State(),
          reducer: { GenderSettingLogic() }
        )
      )
    }
  }
}
