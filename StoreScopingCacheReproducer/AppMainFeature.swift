import ComposableArchitecture
import Foundation
import OrderedCollections

@Reducer
struct AppMain {
  struct State {
    var data: IdentifiedArrayOf<MusicLibraryItem>
    var snapshotData: OrderedDictionary<String, OrderedSet<UUID>>

    init() {
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
      self.data = .init(
        uniqueElements: songNames.map {
          MusicLibraryItem(id: uuid(), name: "\($0)")
        }
      )
      self.snapshotData = .init()
    }

    mutating func refreshSnapshotData(sortInDecreasingOrder: Bool = false) {
      data.sort(by: { first, second in
        if sortInDecreasingOrder {
          first.name > second.name
        } else {
          first.name < second.name
        }
      })
      let data = OrderedDictionary<String, IdentifiedArrayOf<MusicLibraryItem>>(
        grouping: data,
        by: { musicLibraryItem in
          let text = musicLibraryItem.name.first!
          return "\(text)"
        }
      )
      snapshotData = data.compactMapValues { items in
        items.ids
      }
    }
  }

  enum Action {
    case aToZSegmentTapped
    case zToASegmentTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .aToZSegmentTapped:
        state.refreshSnapshotData(sortInDecreasingOrder: false)
        return .none

      case .zToASegmentTapped:
        state.refreshSnapshotData(sortInDecreasingOrder: true)
        return .none
      }
    }
  }
}
