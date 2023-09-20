import ComposableArchitecture
import God
import SwiftUI

public struct PollLogic: Reducer {
  public init() {}

  public struct State: Equatable {
    var pollQuestions: IdentifiedArrayOf<PollQuestionLogic.State>
    
    public init(
      poll: God.CurrentPollQuery.Data.CurrentPoll.Poll
    ) {
      pollQuestions = .init(
        uniqueElements: poll.pollQuestions.map(PollQuestionLogic.State.init)
      )
    }
  }

  public enum Action: Equatable {
    case onTask
    case pollQuestions(id: PollQuestionLogic.State.ID, action: PollQuestionLogic.Action)
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onTask:
        return .none
        
      case .pollQuestions:
        return .none
      }
    }
    .forEach(\.pollQuestions, action: /Action.pollQuestions) {
      PollQuestionLogic()
    }
  }
}

public struct PollView: View {
  let store: StoreOf<PollLogic>

  public init(store: StoreOf<PollLogic>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView {
        ForEachStore(
          store.scope(state: \.pollQuestions, action: PollLogic.Action.pollQuestions),
          content: PollQuestionView.init
        )
      }
      .tabViewStyle(.page)
      .ignoresSafeArea()
      .task { await viewStore.send(.onTask).finish() }
    }
  }
}
