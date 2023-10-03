import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import ProfilePicture
import SwiftUI

public struct FriendRequestCardLogic: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: String {
      friendId
    }

    var friendId: String
    var userId: String
    var imageURL: String
    var displayName: String
    var firstName: String
    var lastName: String
    var description: String
  }

  public enum Action: Equatable {
    case approveButtonTapped
    case hideButtonTapped
    case approveResponse(TaskResult<God.ApproveFriendRequestMutation.Data>)
    case hideResponse(TaskResult<God.CreateUserHideMutation.Data>)
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .approveButtonTapped:
        let input = God.ApproveFriendRequestInput(id: state.friendId)
        return .run { send in
          await send(.approveResponse(TaskResult {
            try await godClient.approveFriendRequest(input)
          }))
        }
      case .hideButtonTapped:
        let input = God.CreateUserHideInput(hiddenUserId: state.userId)
        return .run { send in
          await send(.hideResponse(TaskResult {
            try await godClient.createUserHide(input)
          }))
        }
      case .approveResponse(.success):
        return .none

      case .approveResponse(.failure):
        return .none

      case .hideResponse(.success):
        return .none

      case .hideResponse(.failure):
        return .none
      }
    }
  }
}

public struct FriendRequestCardView: View {
  let store: StoreOf<FriendRequestCardLogic>

  public init(store: StoreOf<FriendRequestCardLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(alignment: .center, spacing: 16) {
        ProfilePicture(
          url: URL(string: viewStore.imageURL),
          familyName: viewStore.lastName,
          givenName: viewStore.firstName,
          size: 42
        )

        VStack(alignment: .leading) {
          Text(verbatim: viewStore.displayName)
            .bold()

          Text(verbatim: viewStore.description)
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        HStack(spacing: 0) {
          Button {
            viewStore.send(.approveButtonTapped)
          } label: {
            Text("APPROVE", bundle: .module)
              .font(.callout)
              .bold()
              .foregroundStyle(Color.white)
              .frame(height: 34)
              .padding(.horizontal, 12)
              .background(Color.godService)
              .clipShape(Capsule())
          }
        }
        .buttonStyle(HoldDownButtonStyle())
      }
      .frame(height: 72)
      .padding(.horizontal, 16)
    }
  }
}
