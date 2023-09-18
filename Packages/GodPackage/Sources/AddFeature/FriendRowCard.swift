import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import SwiftUI

public struct FriendRowCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String
    var displayName: String
    var description: String
    var friendStatus = God.FriendStatus.canceled

    public init(id: String, displayName: String, description: String) {
      self.id = id
      self.displayName = displayName
      self.description = description
    }
  }

  public enum Action: Equatable {
    case addButtonTapped
    case hideButtonTapped
    case friendRequestResponse(TaskResult<God.CreateFriendRequestMutation.Data>)
    case hideResponse(TaskResult<God.CreateUserHideMutation.Data>)
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .addButtonTapped:
        let input = God.CreateFriendRequestInput(toUserId: state.id)
        return .run { send in
          await send(.friendRequestResponse(TaskResult {
            try await godClient.createFriendRequest(input)
          }))
        }
      case .hideButtonTapped:
        state.friendStatus = .requested
        let input = God.CreateUserHideInput(hiddenUserId: state.id)
        return .run { send in
          await send(.hideResponse(TaskResult {
            try await godClient.createUserHide(input)
          }))
        }
      case let .friendRequestResponse(.success(data)):
        guard let status = data.createFriendRequest.status.value
        else { return .none }
        state.friendStatus = status
        return .none

      case .friendRequestResponse(.failure):
        state.friendStatus = .canceled
        return .none

      case .hideResponse(.success):
        return .none

      case .hideResponse(.failure):
        return .none
      }
    }
  }
}

public struct FriendRowCardView: View {
  let store: StoreOf<FriendRowCardLogic>

  public init(store: StoreOf<FriendRowCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        Color.red
          .frame(width: 40, height: 40)
          .clipShape(Circle())

        VStack(alignment: .leading) {
          Text(verbatim: viewStore.displayName)

          Text(verbatim: viewStore.description)
            .foregroundStyle(.secondary)
        }

        HStack(spacing: 0) {
          Button {
            viewStore.send(.hideButtonTapped)
          } label: {
            Text("HIDE", bundle: .module)
              .frame(width: 80, height: 34)
              .foregroundStyle(.secondary)
          }

          Button {
            viewStore.send(.addButtonTapped)
          } label: {
            Group {
              if case .requested = viewStore.friendStatus {
                Text("ADDED")
                  .foregroundStyle(Color.godTextSecondaryLight)
                  .frame(width: 80, height: 34)
                  .overlay(
                    RoundedRectangle(cornerRadius: 34 / 2)
                      .stroke(Color.godTextSecondaryLight, lineWidth: 1)
                  )
              } else {
                Text("ADD", bundle: .module)
                  .foregroundStyle(Color.white)
                  .frame(width: 80, height: 34)
                  .background(Color.godService)
                  .clipShape(Capsule())
              }
            }
          }
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .frame(height: 72)
    }
  }
}

#Preview {
  FriendRowCardView(
    store: .init(
      initialState: FriendRowCardLogic.State(
        id: "1",
        displayName: "Taro Tanaka",
        description: "Grade 9"
      ),
      reducer: { FriendRowCardLogic() }
    )
  )
}
