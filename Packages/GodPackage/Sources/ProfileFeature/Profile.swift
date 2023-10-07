import Colors
import ComposableArchitecture
import God
import GodClient
import ProfileEditFeature
import ProfileShareFeature
import ShopFeature
import SwiftUI

public struct ProfileLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    @PresentationState var destination: Destination.State?
    var profile: God.CurrentUserProfileQuery.Data?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case editProfileButtonTapped
    case shareProfileButtonTapped
    case shopButtonTapped
    case friendButtonTapped(userId: String)
    case profileResponse(TaskResult<God.CurrentUserProfileQuery.Data>)
    case destination(PresentationAction<Destination.Action>)
  }

  @Dependency(\.godClient) var godClient

  enum Cancel {
    case profile
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUserProfile() {
            await send(.profileResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.profileResponse(.failure(error)))
        }
        .cancellable(id: Cancel.profile)

      case .editProfileButtonTapped:
        state.destination = .profileEdit()
        return .none

      case .shareProfileButtonTapped:
        state.destination = .profileShare()
        return .none

      case .shopButtonTapped:
        state.destination = .shop()
        return .none

      case let .friendButtonTapped(userId):
        state.destination = .external(.init(userId: userId))
        return .none

      case let .profileResponse(.success(data)):
        state.profile = data
        return .none
      case .profileResponse(.failure):
        state.profile = nil
        return .none

      case .destination(.dismiss):
        state.destination = nil
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Destination()
    }
  }

  public struct Destination: Reducer {
    public enum State: Equatable {
      case profileEdit(ProfileEditLogic.State = .init())
      case shop(ShopLogic.State = .init())
      case profileShare(ProfileShareLogic.State = .init())
      case external(ProfileExternalLogic.State)
    }

    public enum Action: Equatable {
      case profileEdit(ProfileEditLogic.Action)
      case shop(ShopLogic.Action)
      case profileShare(ProfileShareLogic.Action)
      case external(ProfileExternalLogic.Action)
    }

    public var body: some Reducer<State, Action> {
      Scope(state: /State.profileEdit, action: /Action.profileEdit) {
        ProfileEditLogic()
      }
      Scope(state: /State.shop, action: /Action.shop) {
        ShopLogic()
      }
      Scope(state: /State.profileShare, action: /Action.profileShare) {
        ProfileShareLogic()
      }
      Scope(state: /State.external, action: /Action.external) {
        ProfileExternalLogic()
      }
    }
  }
}

public struct ProfileView: View {
  let store: StoreOf<ProfileLogic>

  public init(store: StoreOf<ProfileLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          if let data = viewStore.profile {
            ProfileSection(
              imageURL: data.currentUser.imageURL,
              friendsCount: data.currentUser.friendsCount ?? 0,
              votedCount: data.currentUser.votedCount,
              username: data.currentUser.username ?? "",
              firstName: data.currentUser.firstName,
              lastName: data.currentUser.lastName,
              displayName: data.currentUser.displayName.ja,
              schoolShortName: data.currentUser.school?.shortName,
              grade: data.currentUser.grade
            ) {
              viewStore.send(.editProfileButtonTapped)
            }

            Divider()

            ShareShopSection(
              coinBalance: data.currentUser.wallet?.coinBalance ?? 0,
              shareAction: {
                viewStore.send(.shareProfileButtonTapped)
              },
              shopAction: {
                viewStore.send(.shopButtonTapped)
              }
            )

            Divider()
            
            if !data.questionsOrderByVotedDesc.isEmpty {
              TopStarsSection(
                questions: data.questionsOrderByVotedDesc
              )
              .padding(.bottom, 16)
            }
            
            if !data.friends.isEmpty {
              FriendsSection(friends: data.friends.map(\.fragments.friendFragment)) { state in
                viewStore.send(.friendButtonTapped(userId: state.id))
              }
            }
          }
        }
        .background(Color.godBackgroundWhite)
      }
      .listStyle(.plain)
      .navigationTitle(Text("Profile", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.onTask).finish() }
      .fullScreenCover(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.profileEdit,
        action: ProfileLogic.Destination.Action.profileEdit
      ) { store in
        NavigationStack {
          ProfileEditView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.shop,
        action: ProfileLogic.Destination.Action.shop
      ) { store in
        NavigationStack {
          ShopView(store: store)
        }
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.profileShare,
        action: ProfileLogic.Destination.Action.profileShare
      ) { store in
        ProfileShareView(store: store)
          .presentationDetents([.height(ProfileShareView.heightForPresentationDetents)])
          .presentationCornerRadiusIfPossible(24)
      }
      .sheet(
        store: store.scope(state: \.$destination, action: { .destination($0) }),
        state: /ProfileLogic.Destination.State.external,
        action: ProfileLogic.Destination.Action.external
      ) { store in
        NavigationStack {
          ProfileExternalView(store: store)
        }
      }
    }
  }
}

extension View {
  @ViewBuilder
  func presentationCornerRadiusIfPossible(_ cornerRadius: CGFloat) -> some View {
    if #available(iOS 16.4, *) {
      self.presentationCornerRadius(cornerRadius)
    } else {
      self
    }
  }
}

struct ProfileViewPreviews: PreviewProvider {
  static var previews: some View {
    ProfileView(
      store: .init(
        initialState: ProfileLogic.State(),
        reducer: { ProfileLogic() }
      )
    )
  }
}
