import ComposableArchitecture
import Foundation
import UIKit

extension MusicLibraryViewController {
  typealias Section = MusicLibrarySection
  typealias Item = UUID

  class CollectionViewDataSource: UICollectionViewDiffableDataSource<Section, Item> {
    init(store: StoreOf<MusicLibrary>, collectionView: UICollectionView) {
      let headerRegistration = UICollectionView.SupplementaryRegistration<MusicLibrarySectionCell>(
        elementKind: UICollectionView.elementKindSectionHeader
      ) {
        [weak store] headerView, _, indexPath in
        guard let store else { return }

        if
          let item = store.withState(\.snapshotData.sections[safeIndex: indexPath.section])
        {
          print("Store.withState:", item)
        }
        if let scopedState = store.scope(
          state: \.snapshotData.sections[safeIndex: indexPath.section],
          action: \.self
          //    state: { $0.snapshotData.sections[safeIndex: indexPath.section] },
          //    action: { $0 }
        ).withState({ $0 }) {
          print("ScopedStore.withState", scopedState)
        }

        store.scope(
          state: \.snapshotData.sections[safeIndex: indexPath.section],
          action: \.self
        ).ifLet { [weak headerView] store in
          headerView?.update(with: store)
        }
        .store(in: &headerView.cancellables)
      }

      let musicLibraryItemCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell, UUID
      > { [weak store] cell, _, itemId in
        guard let store else { return }

        store.scope(
          state: \.data[id: itemId],
          action: { $0 }
        ).ifLet { [weak cell] store in
          var configuration = UIListContentConfiguration.cell()
          configuration.text = store.withState(\.name)
          cell?.contentConfiguration = configuration
        }
      }

      super.init(collectionView: collectionView) { collectionView, indexPath, itemId in
        collectionView.dequeueConfiguredReusableCell(
          using: musicLibraryItemCellRegistration,
          for: indexPath,
          item: .init(itemId)
        )
      }

      supplementaryViewProvider = {
        collectionView, _, indexPath -> UICollectionReusableView? in
        collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration,
          for: indexPath
        )
      }
    }
  }
}
