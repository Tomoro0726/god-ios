import ComposableArchitecture
import God
import GodClient
import FirebaseAuth
import FirebaseAuthClient

public struct OnboardAuthLogic: Reducer {
  @Dependency(\.godClient) var godClient
  @Dependency(\.firebaseAuth) var firebaseAuth
  @Dependency(\.phoneNumberClient) var phoneNumberClient
  
  public func reduce(
    into state: inout OnboardReducer.State,
    action: OnboardReducer.Action
  ) -> Effect<OnboardReducer.Action> {
    switch action {
    case let .path(.element(_, action)):
      switch action {
      case let .phoneNumber(.delegate(.changePhoneNumber(phoneNumber))):
        state.auth.phoneNumber = phoneNumber
        return .none
        
      case let .oneTimeCode(.delegate(.changeOneTimeCode(oneTimeCode))):
        state.auth.oneTimeCode = oneTimeCode
        return .none
        
        
      case .phoneNumber(.delegate(.nextScreen)):
        return .run { [state] send in
          let phoneNumber = state.auth.phoneNumber
          let formatNumber = try phoneNumberClient.parseFormat(phoneNumber)
          await send(
            .verifyResponse(
              TaskResult {
                try await firebaseAuth.verifyPhoneNumber(formatNumber)
              }
            ),
            animation: .default
          )
        }
      case .oneTimeCode(.delegate(.resend)):
        return .run { [state] send in
          let phoneNumber = state.auth.phoneNumber
          let formatNumber = try phoneNumberClient.parseFormat(phoneNumber)
          await send(
            .verifyResponse(
              TaskResult {
                try await firebaseAuth.verifyPhoneNumber(formatNumber)
              }
            ),
            animation: .default
          )
        }
      case .oneTimeCode(.delegate(.send)):
        state.auth.isActivityIndicatorVisible = true
        return .run { [state] send in
          let verifyId = state.auth.verifyId
          let oneTimeCode = state.auth.oneTimeCode
          let credential = firebaseAuth.credential(verifyId, oneTimeCode)
          await send(
            .signInResponse(
              TaskResult {
                try await firebaseAuth.signIn(credential)
              }
            ),
            animation: .default
          )
        }
      default:
        return .none
      }
      
    case let .verifyResponse(.success(.some(id))):
      state.auth.verifyId = id
      return .none

    case let .verifyResponse(.failure(error)):
      state.alert = AlertState {
        TextState("Error")
      } message: {
        TextState(error.localizedDescription)
      }
      return .none
      
    case .signInResponse(.success):
      return .run { [state] send in
        let format = try phoneNumberClient.parseFormat(state.auth.phoneNumber)
        let phoneNumber = God.PhoneNumberInput(
          countryCode: "+81",
          numbers: format.replacing("+81", with: "")
        )
        let input = God.CreateUserInput(phoneNumber: phoneNumber)
        await send(
          .createUserResponse(
            TaskResult {
              try await godClient.createUser(input)
            }
          ),
          animation: .default
        )
      }
      
    case let .signInResponse(.failure(error)):
      state.auth.isActivityIndicatorVisible = false
      state.alert = AlertState {
        TextState("Error")
      } message: {
        TextState(error.localizedDescription)
      }
      return .none
      
    case .createUserResponse(.success):
      return .run { [state] send in
        let schoolId: GraphQLNullable<String> = state.schoolId ?? nil
        let generation: GraphQLNullable<Int> = state.generation ?? nil
        let input = God.UpdateUserProfileInput(
          generation: generation,
          schoolId: schoolId
        )
        await send(
          .updateProfileResponse(
            TaskResult {
              try await godClient.updateUserProfile(input)
            }
          ),
          animation: .default
        )
      }
    case .createUserResponse(.failure):
      state.auth.isActivityIndicatorVisible = false
      state.path.removeAll()
      return .none
      
    case .updateProfileResponse:
      state.auth.isActivityIndicatorVisible = false
      state.path.append(.firstNameSetting())
      return .none

    default:
      return .none
    }
  }
}
