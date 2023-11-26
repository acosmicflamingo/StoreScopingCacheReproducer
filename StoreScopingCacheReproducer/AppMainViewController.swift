import Combine
import ComposableArchitecture
import SnapKit
import UIKit

class AppMainViewController: UIViewController {
  var store: StoreOf<AppMain>
  var cancellables = Set<AnyCancellable>()

  lazy var segmentedControl: UISegmentedControl = {
    let view = UISegmentedControl()
    view.insertSegment(action: .init(title: "A to Z") { [weak store] _ in
      store?.send(.aToZSegmentTapped)
    }, at: 0, animated: false)
    view.insertSegment(action: .init(title: "Z to A") { [weak store] _ in
      store?.send(.zToASegmentTapped)
    }, at: 1, animated: false)
    return view
  }()

  let collectionView: UICollectionView = {
    var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    layoutConfig.headerMode = .supplementary
    let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
    let view = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    return view
  }()

  var dataSource: UICollectionViewDiffableDataSource<String, UUID>?

  init(store: StoreOf<AppMain>) {
    self.store = store

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupBindings()
  }

  private func setupUI() {
    view.backgroundColor = UIColor.systemGray5

    view.addSubview(segmentedControl)
    segmentedControl.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.layoutMarginsGuide)
    }

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(segmentedControl.snp.bottom).offset(16)
      make.leading.bottom.trailing.equalTo(view.layoutMarginsGuide)
    }

    let headerRegistration = UICollectionView.SupplementaryRegistration<
      UICollectionViewListCell
    >(
      elementKind: UICollectionView.elementKindSectionHeader
    ) {
      [weak store] headerView, _, indexPath in
      guard let store else { return }

      if
        let item = store.withState(\.snapshotData.keys.elements[safeIndex: indexPath.section])
      {
        print("Store.withState:", item)
      }
      if let scopedState = store.scope(
        state: \.snapshotData.keys.elements[safeIndex: indexPath.section],
        action: \.self
        //    state: { $0.snapshotData.sections[safeIndex: indexPath.section] },
        //    action: { $0 }
      ).withState({ $0 }) {
        print("ScopedStore.withState", scopedState)
      }

      store.scope(
        state: \.snapshotData.keys.elements[safeIndex: indexPath.section],
        action: \.self
      ).ifLet { [weak headerView] store in
        var newBackgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        newBackgroundConfiguration.backgroundColor = UIColor.systemGray5
        headerView?.backgroundConfiguration = newBackgroundConfiguration

        var newConfiguration = UIListContentConfiguration.groupedHeader()
        let text = store.withState({ $0 })
        newConfiguration.text = text
        print("UICollectionViewListCell updated with \(text)")
        headerView?.contentConfiguration = newConfiguration
      }
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

    let dataSource = UICollectionViewDiffableDataSource<String, UUID>(
      collectionView: self.collectionView
    ) { collectionView, indexPath, itemId in
      return collectionView.dequeueConfiguredReusableCell(
        using: musicLibraryItemCellRegistration,
        for: indexPath,
        item: itemId
      )
    }

    dataSource.supplementaryViewProvider = {
      collectionView, _, indexPath -> UICollectionReusableView? in

      return collectionView.dequeueConfiguredReusableSupplementary(
        using: headerRegistration,
        for: indexPath
      )
    }
    self.dataSource = dataSource
  }

  private func setupBindings() {
    store.publisher.snapshotData
      .removeDuplicates(by: ==)
      .sink { [weak self] snapshotData in
        guard let self else { return }

        var snapshot = NSDiffableDataSourceSnapshot<String, UUID>()
        for (section, items) in snapshotData {
          let itemIds = items.elements
          snapshot.appendSections([section])
          snapshot.appendItems(itemIds, toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
      }
      .store(in: &cancellables)
  }
}

