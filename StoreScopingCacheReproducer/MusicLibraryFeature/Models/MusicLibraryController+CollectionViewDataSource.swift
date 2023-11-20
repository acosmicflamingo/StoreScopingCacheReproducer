import Combine
import Foundation
import OrderedCollections
import UIKit

public typealias SnapshotData<Section: Hashable, Item: Hashable> = OrderedDictionary<
  Section, OrderedSet<Item>
>

extension SnapshotData {
  public var sections: [Key] {
    keys.elements
  }
}

extension SnapshotData {
  public func snapshot<Element>() -> NSDiffableDataSourceSnapshot<Key, Element>
    where Value == OrderedSet<Element>
  {
    var snapshot = NSDiffableDataSourceSnapshot<Key, Element>()
    for (section, items) in self {
      let itemIds = items.elements
      snapshot.appendSections([section])
      snapshot.appendItems(itemIds, toSection: section)
    }
    return snapshot
  }
}

extension SnapshotData where Value == OrderedSet<UUID> {
  public var items: OrderedSet<UUID> {
    .init(reduce(into: []) { partialResult, result in
      partialResult += result.value
    })
  }

  public func key(from element: UUID) -> Key? {
    first(where: { $0.value.contains(element) })?.key
  }
}

extension Publisher {
  public func generateSnapshot<Section: Hashable, Item: Hashable>() -> some Publisher<
    NSDiffableDataSourceSnapshot<Section, Item>, Never
  > where
    Output: Equatable & Sequence,
    Output == SnapshotData<Section, Item>,
    Failure == Never
  {
    self
      .removeDuplicates(by: ==)
      .map { $0.snapshot() }
  }

  public func trackItemIdentifierDidChange<Section: Hashable, Item: Hashable>() -> some Publisher<
    (current: NSDiffableDataSourceSnapshot<Section, Item>,
     itemIdentifierDidChange: Bool),
    Self.Failure
  > where
    Output == NSDiffableDataSourceSnapshot<Section, Item>
  {
    self
      .withPrevious()
      .map { snapshots in
        let previousItemCount = snapshots.previous?.itemIdentifiers.count ?? -1
        let currentItemCount = snapshots.current.itemIdentifiers.count
        let itemIdentifierDidChange = previousItemCount != currentItemCount
        return (current: snapshots.current, itemIdentifierDidChange: itemIdentifierDidChange)
      }
  }

  public func withPreviousAndTrackItemIdentifierDidChange<
    Section: Hashable, Item: Hashable
  >() -> some Publisher<
    (previous: NSDiffableDataSourceSnapshot<Section, Item>?,
     current: NSDiffableDataSourceSnapshot<Section, Item>,
     itemIdentifierDidChange: Bool),
    Self.Failure
  > where
    Output == NSDiffableDataSourceSnapshot<Section, Item>
  {
    self
      .withPrevious()
      .map { snapshots in
        let previousItemCount = snapshots.previous?.itemIdentifiers.count ?? -1
        let currentItemCount = snapshots.current.itemIdentifiers.count
        let itemIdentifierDidChange = previousItemCount != currentItemCount
        return (
          previous: snapshots.previous,
          current: snapshots.current,
          itemIdentifierDidChange: itemIdentifierDidChange
        )
      }
  }
}
