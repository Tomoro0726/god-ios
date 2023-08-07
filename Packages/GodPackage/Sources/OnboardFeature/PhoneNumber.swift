import Colors
import ComposableArchitecture
import PhoneNumberKit
import SwiftUI
import FirebaseAuthClient
import PhoneNumberClient

public struct PhoneNumberReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    var phoneNumber = ""
    @PresentationState var alert: AlertState<Action.Alert>?
    public init() {}
  }

  public enum Action: Equatable {
    case onTask
    case changePhoneNumber(String)
    case nextButtonTapped
    case verifyResponse(TaskResult<String?>)
    case alert(PresentationAction<Alert>)
    case delegate(Delegate)
    
    public enum Alert: Equatable {
      case confirmOkay
    }

    public enum Delegate: Equatable {
      case nextOneTimeCode(verifyID: String)
    }
  }
  
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.phoneNumberClient) var phoneNumberClient

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onTask:
        return .none

      case let .changePhoneNumber(phoneNumber):
        state.phoneNumber = phoneNumber
        return .none

      case .nextButtonTapped:
        return .run { [phoneNumber = state.phoneNumber] send in
          let formatNumber = try phoneNumberClient.parseFormat(phoneNumber)
          await send(
            .verifyResponse(
              await TaskResult {
                try await self.firebaseAuth.verifyPhoneNumber(formatNumber)
              }
            )
          )
        }
      case let .verifyResponse(.success(.some(id))):
        return .run { send in
          await send(.delegate(.nextOneTimeCode(verifyID: id)))
        }
      case .verifyResponse(.success(.none)):
        print("verify id is null")
        return .none
        
      case let .verifyResponse(.failure(error)):
        state.alert = AlertState {
          TextState("Error")
        } actions: {
          ButtonState(action: .confirmOkay) {
            TextState("OK")
          }
        } message: {
          TextState(error.localizedDescription)
        }
        return .none
        
      case .alert:
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

public struct PhoneNumberView: View {
  let store: StoreOf<PhoneNumberReducer>

  public init(store: StoreOf<PhoneNumberReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ZStack {
        Color.god.service
          .ignoresSafeArea()

        VStack(spacing: 12) {
          Spacer()
          Text("Enter your phone Number")
            .bold()
            .font(.title3)

          TextField(
            "Phone Number",
            text: viewStore.binding(
              get: \.phoneNumber,
              send: PhoneNumberReducer.Action.changePhoneNumber
            )
          )
          .font(.title)
          .textContentType(.telephoneNumber)
          .keyboardType(.phonePad)

          Text("Remember - never sign up\nwith another person's phone number.")
            .multilineTextAlignment(.center)

          Spacer()

          Button {
            viewStore.send(.nextButtonTapped)
          } label: {
            Text("Next")
              .bold()
              .frame(height: 56)
              .frame(maxWidth: .infinity)
          }
          .foregroundColor(Color.god.textPrimary)
          .background(Color.white)
          .clipShape(Capsule())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
      }
      .navigationBarBackButtonHidden()
      .alert(store: store.scope(state: \.$alert, action: PhoneNumberReducer.Action.alert))
    }
  }
}

struct PhoneNumberViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneNumberView(
      store: .init(
        initialState: PhoneNumberReducer.State(),
        reducer: { PhoneNumberReducer() }
      )
    )
  }
}
