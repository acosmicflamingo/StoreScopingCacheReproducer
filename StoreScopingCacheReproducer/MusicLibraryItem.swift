import Foundation
import UIKit

struct MusicLibraryItem: Equatable, Hashable, Identifiable {
  var id: UUID
  var name: String

  init(id: UUID = .init(), name: String) {
    self.id = id
    self.name = name
  }
}
