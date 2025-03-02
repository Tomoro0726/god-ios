import ButtonStyles
import Colors
import ComposableArchitecture
import God
import GodClient
import StoreKit
import StoreKitClient
import StoreKitHelpers
import SwiftUI

public struct GodModeLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var product: Product
    var currentUser: God.CurrentUserQuery.Data.CurrentUser?
    var isActivityIndicatorVisible = false

    public init(product: Product) {
      self.product = product
    }
  }

  public enum Action: Equatable {
    case onTask
    case maybeLaterButtonTapped
    case continueButtonTapped
    case purchaseResponse(TaskResult<StoreKit.Transaction>)
    case transactionFinish(StoreKit.Transaction)
    case currentUserResponse(TaskResult<God.CurrentUserQuery.Data>)
    case delegate(Delegate)

    public enum Delegate: Equatable {
      case activated
    }
  }

  @Dependency(\.dismiss) var dismiss
  @Dependency(\.store) var storeClient
  @Dependency(\.godClient) var godClient

  enum Cancel {
    case id
    case currentUser
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .run { send in
          for try await data in godClient.currentUser() {
            await send(.currentUserResponse(.success(data)))
          }
        } catch: { error, send in
          await send(.currentUserResponse(.failure(error)))
        }
        .cancellable(id: Cancel.currentUser, cancelInFlight: true)

      case .maybeLaterButtonTapped:
        return .run { _ in
          await dismiss()
        }
      case .continueButtonTapped:
        guard let userId = state.currentUser?.id else { return .none }
        guard let token = UUID(uuidString: userId) else { return .none }
        state.isActivityIndicatorVisible = true
        return .run { [state] send in
          let result = try await storeClient.purchase(state.product, token)
          switch result {
          case let .success(verificationResult):
            await send(.purchaseResponse(TaskResult {
              try checkVerified(verificationResult)
            }))
          case .pending:
            await send(.purchaseResponse(.failure(InAppPurchaseError.pending)))
          case .userCancelled:
            await send(.purchaseResponse(.failure(InAppPurchaseError.userCancelled)))
          @unknown default:
            fatalError()
          }
        } catch: { error, send in
          await send(.purchaseResponse(.failure(error)))
        }
        .cancellable(id: Cancel.id)
      case let .purchaseResponse(.success(transaction)):
        state.isActivityIndicatorVisible = false
        return .run { send in
          let data = try await godClient.createTransaction(transaction.id.description)
          guard data.createTransaction else { return }
          await send(.transactionFinish(transaction))
        }
      case let .purchaseResponse(.failure(error as VerificationResult<StoreKit.Transaction>.VerificationError)):
        state.isActivityIndicatorVisible = false
        print(error)
        return .none
      case let .purchaseResponse(.failure(error as InAppPurchaseError)):
        state.isActivityIndicatorVisible = false
        print(error)
        return .none
      case .purchaseResponse(.failure):
        state.isActivityIndicatorVisible = false
        return .none

      case let .transactionFinish(transaction):
        return .run { send in
          await transaction.finish()
          await send(.delegate(.activated), animation: .default)
        }

      case let .currentUserResponse(.success(data)):
        state.currentUser = data.currentUser
        return .none

      case .currentUserResponse(.failure):
        return .none
      case .delegate:
        return .none
      }
    }
  }
}

public struct GodModeView: View {
  let store: StoreOf<GodModeLogic>

  public init(store: StoreOf<GodModeLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: 24) {
        VStack(spacing: 0) {
          Text("Recurring billing. Cancel anytime.", bundle: .module)
          Text("Your payment will be charged to iTunes Account, and your subscription will auto-renew for \(viewStore.product.displayPrice)/week until you cancel in iTunes Store settings. By tapping Unlock, you agree to our Terms and the auto-renewal.", bundle: .module)
        }
        .font(.caption)
        .padding(.horizontal, 24)
        .foregroundColor(Color.gray)
        .multilineTextAlignment(.center)

        VStack(spacing: 16) {
          VStack(spacing: 0) {
            Image(.seeWhoLikesYou)
              .resizable()
              .scaledToFit()
              .padding(.horizontal, 60)

            GodModeFunctions()
          }

          Text("\(viewStore.product.displayPrice)/week", bundle: .module)
            .bold()

          Button {
            store.send(.continueButtonTapped)
          } label: {
            Group {
              if viewStore.isActivityIndicatorVisible {
                ProgressView()
                  .progressViewStyle(.circular)
              } else {
                Text("Continue", bundle: .module)
                  .bold()
              }
            }
            .bold()
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .tint(Color.white)
            .background(Color.orange.gradient)
            .clipShape(Capsule())
            .padding(.horizontal, 60)
          }
          .buttonStyle(HoldDownButtonStyle())

          Button {
            store.send(.maybeLaterButtonTapped)
          } label: {
            Text("Maybe Later", bundle: .module)
              .foregroundColor(Color.gray)
          }
          .buttonStyle(HoldDownButtonStyle())
        }
        .disabled(viewStore.isActivityIndicatorVisible)
        .foregroundColor(Color.white)
        .padding(.vertical, 24)
        .background(Color.black.gradient)
        .cornerRadius(32 / 2)
        .overlay(
          RoundedRectangle(cornerRadius: 32 / 2)
            .stroke(Color.orange, lineWidth: 2)
        )
        .padding(.horizontal, 8)

        Spacer()
      }
      .background(Color.godBlack)
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
