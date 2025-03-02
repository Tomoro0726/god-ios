import AsyncValue
import CachedAsyncImage
import Colors
import ComposableArchitecture
import God
import GodClient
import RoundedCorner
import SwiftUI

public struct SchoolSettingLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var schools = AsyncValue<[God.SchoolsQuery.Data.Schools.Edge.Node]>.none
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case schoolButtonTapped(id: String)
    case schoolsResponse(TaskResult<God.SchoolsQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case nextScreen(id: String?)
    }
  }

  @Dependency(\.godClient) var godClient

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        state.schools = .loading
        return .run { send in
          for try await data in godClient.schools() {
            await send(.schoolsResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.schoolsResponse(.failure(error)))
        }

      case let .schoolButtonTapped(id):
        return .send(.delegate(.nextScreen(id: id)))

      case let .schoolsResponse(.success(data)):
        state.schools = .success(data.schools.edges.map(\.node))
        return .none

      case let .schoolsResponse(.failure(error)):
        state.schools = .failure(error)
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct SchoolSettingView: View {
  let store: StoreOf<SchoolSettingLogic>

  public init(store: StoreOf<SchoolSettingLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack(alignment: .center) {
        Color.godService

        switch viewStore.schools {
        case let .success(schools):
          List(schools, id: \.self) { school in
            Button {
              viewStore.send(.schoolButtonTapped(id: school.id))
            } label: {
              HStack(alignment: .center, spacing: 16) {
                SchoolImage(urlString: school.profileImageURL)

                VStack(alignment: .leading) {
                  Text(school.name)
                    .bold()
                    .lineLimit(1)

                  Text(school.shortName)
                    .foregroundColor(Color.godTextSecondaryLight)
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                  Text(school.usersCount.description)
                    .bold()
                    .foregroundColor(Color.godService)
                  Text("MEMBERS", bundle: .module)
                    .foregroundColor(Color.godTextSecondaryLight)
                }
                .font(.footnote)
              }
            }
          }
          .listStyle(.plain)
          .foregroundColor(.primary)
          .background(Color.white)
          .multilineTextAlignment(.center)
          .cornerRadius(12, corners: [.topLeft, .topRight])
          .edgesIgnoringSafeArea(.bottom)

        case .loading:
          Color.white
            .ignoresSafeArea()
            .overlay {
              ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.black)
            }

        default:
          Color.white
            .ignoresSafeArea()
        }
      }
      .task { await viewStore.send(.onTask).finish() }
      .navigationTitle(Text("Pick your school", bundle: .module))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Color.godService, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
  }

  struct SchoolImage: View {
    let urlString: String
    var body: some View {
      CachedAsyncImage(url: URL(string: urlString)) { phase in
        switch phase {
        case let .success(image):
          image.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 40, height: 40)
            .background(Color.godBackgroundWhite)
            .clipShape(Circle())

        case .failure:
          Image(ImageResource.school)
            .resizable()
            .frame(width: 40, height: 40)
            .scaledToFit()
            .clipped()

        default:
          RoundedRectangle(cornerRadius: 40 / 2, style: .circular)
            .fill(Color.godBackgroundWhite)
            .frame(width: 40, height: 40)
            .overlay {
              ProgressView()
                .progressViewStyle(.circular)
            }
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    SchoolSettingView(
      store: .init(
        initialState: SchoolSettingLogic.State(),
        reducer: { SchoolSettingLogic() }
      )
    )
  }
}
