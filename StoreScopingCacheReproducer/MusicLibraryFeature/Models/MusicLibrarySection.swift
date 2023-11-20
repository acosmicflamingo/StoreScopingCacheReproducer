import CasePaths
import Foundation

@CasePathable
@dynamicMemberLookup
public enum MusicLibrarySection: Equatable, Hashable {
  case first(String)
  case second(String)

  public var text: String {
    switch self {
    case let .first(string):
      string

    case let .second(string):
      string
    }
  }
}

extension MusicLibrarySection: Comparable {
  public static func < (lhs: MusicLibrarySection, rhs: MusicLibrarySection) -> Bool {
    lhs.text < rhs.text
  }
}
