import ComposableArchitecture
import Foundation

@Reducer
struct AppMain {
  struct State {
    var musicLibrary: MusicLibrary.State

    init(musicLibrary: MusicLibrary.State = .init()) {
      self.musicLibrary = musicLibrary
    }
  }

  enum Action {
    case musicLibrary(MusicLibrary.Action)
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.musicLibrary, action: \.musicLibrary) {
      MusicLibrary()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .musicLibrary:
        return .none
      }
    }
  }
}
