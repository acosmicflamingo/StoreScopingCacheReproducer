import Combine
import ComposableArchitecture
import Foundation
import UIKit

final class MusicLibrarySectionCell: UICollectionViewListCell {
  typealias State = MusicLibrarySection
  var store: Store<State, MusicLibrary.Action>?
  var cancellables = Set<AnyCancellable>()

  override  func prepareForReuse() {
    super.prepareForReuse()

    store = nil
    cancellables.removeAll()
  }

  override  func updateConfiguration(using state: UICellConfigurationState) {
    guard let viewStore = store?.withState({ $0 }) else { return }

    var newBackgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
    newBackgroundConfiguration.backgroundColor = UIColor.systemGray5
    backgroundConfiguration = newBackgroundConfiguration

    var newConfiguration = UIListContentConfiguration.groupedHeader()
    newConfiguration.text = viewStore.text
    print("MusicLibrarySectionCell updated with \(viewStore.text)")
    contentConfiguration = newConfiguration
  }

  func update(with store: Store<State, MusicLibrary.Action>) {
    self.store = store
  }
}

// swiftformat:enable braces indent
