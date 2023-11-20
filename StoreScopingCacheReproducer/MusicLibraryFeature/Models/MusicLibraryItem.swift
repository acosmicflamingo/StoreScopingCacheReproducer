import CasePaths
import Foundation
import UIKit

protocol IdentifiableByUUID: Identifiable where ID == UUID {}

struct MusicLibraryItem: Equatable, Hashable, IdentifiableByUUID {
  var id: UUID
  var name: String

  init(
    id: UUID = .init(),
    name: String
  ) {
    self.id = id
    self.name = name
  }
}
