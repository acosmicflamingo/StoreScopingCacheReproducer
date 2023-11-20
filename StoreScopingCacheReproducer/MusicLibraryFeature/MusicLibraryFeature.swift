import ComposableArchitecture
import Foundation
import OrderedCollections

@Reducer
struct MusicLibrary {
  struct State {
    var data: IdentifiedArrayOf<MusicLibraryItem>
    var snapshotData: SnapshotData<MusicLibrarySection, UUID>

    init(
      data: [MusicLibraryItem] = {
        @Dependency(\.uuid) var uuid
        let songNames = [
          "Carry On My Wayward Blob",
          "Enter Blobman",
          "Blobs",
          "Hotel Blobifornia",
          "Highway to Blob",
          "Another Blob In The Wall",
          "Blackblob",
          "Hey Blob",
          "What A Wonderful Blob",
          "Shape of Blob",
          "Bad Blob",
          "Disengage The Blob",
          "99 Quite Bitter Blobs",
          "99 Red Blobs",
          "How High The Blob",
          "Autumn Blobs",
          "Blobs In The UK",
          "Blobs On Parade",
          "Blue Blob",
        ]
        return songNames.map {
          .init(id: uuid(), name: "\($0)")
        }
      }(),
      snapshotData: SnapshotData<MusicLibrarySection, UUID> = .init()
    ) {
      self.data = .init(uniqueElements: data)
      self.snapshotData = snapshotData
    }
  }

  enum Action {
    case onInit
    case firstAToZSegmentTapped
    case firstZToASegmentTapped
    case secondAToZSegmentTapped
    case secondZToASegmentTapped

  }

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onInit:
        state.data.sort(by: { first, second in
          first.name < second.name
        })
        let data = OrderedDictionary<
          MusicLibrarySection, IdentifiedArrayOf<MusicLibraryItem>
        >(grouping: state.data, by: { musicLibraryItem in
          let text = musicLibraryItem.name.first ?? "#"
          return .first("\(text)")
        })
        state.snapshotData = data.compactMapValues { items in
          items.ids
        }
        return .none

      case .firstAToZSegmentTapped:
        state.data.sort(by: { first, second in
          first.name < second.name
        })
        let data = OrderedDictionary<
          MusicLibrarySection, IdentifiedArrayOf<MusicLibraryItem>
        >(grouping: state.data, by: { musicLibraryItem in
          let text = musicLibraryItem.name.first ?? "#"
          return .first("\(text)")
        })
        state.snapshotData = data.compactMapValues { items in
          items.ids
        }
        return .none

      case .firstZToASegmentTapped:
        state.data.sort(by: { first, second in
          first.name > second.name
        })
        let data = OrderedDictionary<
          MusicLibrarySection, IdentifiedArrayOf<MusicLibraryItem>
        >(grouping: state.data, by: { musicLibraryItem in
          let text = musicLibraryItem.name.first ?? "#"
          return .first("\(text)")
        })
        state.snapshotData = data.compactMapValues { items in
          items.ids
        }
        return .none

      case .secondAToZSegmentTapped:
        state.data.sort(by: { first, second in
          first.name < second.name
        })
        let data = OrderedDictionary<
          MusicLibrarySection, IdentifiedArrayOf<MusicLibraryItem>
        >(grouping: state.data, by: { musicLibraryItem in
          var name = musicLibraryItem.name
          name.removeFirst()
          let text = name.first ?? "#"
          return .second("\(text)")
        })
        state.snapshotData = data.compactMapValues { items in
          items.ids
        }
        return .none

      case .secondZToASegmentTapped:
        state.data.sort(by: { first, second in
          first.name > second.name
        })
        let data = OrderedDictionary<
          MusicLibrarySection, IdentifiedArrayOf<MusicLibraryItem>
        >(grouping: state.data, by: { musicLibraryItem in
          var name = musicLibraryItem.name
          name.removeFirst()
          let text = name.first ?? "#"
          return .second("\(text)")
        })
        state.snapshotData = data.compactMapValues { items in
          items.ids
        }
        return .none
      }
    }
  }
}
