import Combine
import ComposableArchitecture
import SnapKit
import UIKit

class MusicLibraryViewController: UIViewController {
  var store: StoreOf<MusicLibrary>
  var cancellables = Set<AnyCancellable>()

  lazy var segmentedControl: UISegmentedControl = {
    let view = UISegmentedControl()
    view.insertSegment(action: .init(title: "A->Z") { [weak store] _ in
      store?.send(.firstAToZSegmentTapped)
    }, at: 0, animated: false)
    view.insertSegment(action: .init(title: "Z->A") { [weak store] _ in
      store?.send(.firstZToASegmentTapped)
    }, at: 1, animated: false)
    view.insertSegment(action: .init(title: "2nd A->Z") { [weak store] _ in
      store?.send(.secondAToZSegmentTapped)
    }, at: 2, animated: false)
    view.insertSegment(action: .init(title: "2nd Z->A") { [weak store] _ in
      store?.send(.secondZToASegmentTapped)
    }, at: 3, animated: false)
    view.selectedSegmentIndex = 0
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

  lazy var dataSource = CollectionViewDataSource(
    store: self.store,
    collectionView: self.collectionView
  )

  init(store: StoreOf<MusicLibrary>) {
    self.store = store

    super.init(nibName: nil, bundle: nil)

    store.send(.onInit)
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
  }

  private func setupBindings() {
    store.publisher.snapshotData
      .removeDuplicates(by: ==)
      .compactMap { [weak self] snapshotData in
        guard let self else { return nil }

        var snapshot = snapshotData.snapshot()
        return snapshot
      }
      .sink { [weak self] (
        snapshot: NSDiffableDataSourceSnapshot<Section, Item>
      ) in
        guard let self else { return }

        dataSource.apply(snapshot, animatingDifferences: true)
      }
      .store(in: &cancellables)
  }
}

