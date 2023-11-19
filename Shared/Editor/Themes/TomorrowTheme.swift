import Runestone
import UIKit

extension UIColor {
  struct Tomorrow {
    var background: UIColor {
      return .white
    }

    var selection: UIColor {
      return UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
    }

    var currentLine: UIColor {
      return UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
    }

    var foreground: UIColor {
      return UIColor(red: 96 / 255, green: 96 / 255, blue: 95 / 255, alpha: 1)
    }

    var comment: UIColor {
      return UIColor(red: 159 / 255, green: 161 / 255, blue: 158 / 255, alpha: 1)
    }

    var red: UIColor {
      return UIColor(red: 196 / 255, green: 74 / 255, blue: 62 / 255, alpha: 1)
    }

    var orange: UIColor {
      return UIColor(red: 236 / 255, green: 157 / 255, blue: 68 / 255, alpha: 1)
    }

    var yellow: UIColor {
      return UIColor(red: 232 / 255, green: 196 / 255, blue: 66 / 255, alpha: 1)
    }

    var green: UIColor {
      return UIColor(red: 136 / 255, green: 154 / 255, blue: 46 / 255, alpha: 1)
    }

    var aqua: UIColor {
      return UIColor(red: 100 / 255, green: 166 / 255, blue: 173 / 255, alpha: 1)
    }

    var blue: UIColor {
      return UIColor(red: 94 / 255, green: 133 / 255, blue: 184 / 255, alpha: 1)
    }

    var purple: UIColor {
      return UIColor(red: 149 / 255, green: 115 / 255, blue: 179 / 255, alpha: 1)
    }

    fileprivate init() {}
  }

  static let tomorrow = Tomorrow()
}

final class TomorrowTheme: EditorTheme {
  let backgroundColor: UIColor = .tomorrow.background
  let userInterfaceStyle: UIUserInterfaceStyle = .light

  let font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
  let textColor: UIColor = .tomorrow.foreground

  let gutterBackgroundColor: UIColor = .tomorrow.currentLine
  let gutterHairlineColor: UIColor = .opaqueSeparator

  let lineNumberColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.5)
  let lineNumberFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)

  let selectedLineBackgroundColor: UIColor = .tomorrow.currentLine
  let selectedLinesLineNumberColor: UIColor = .tomorrow.foreground
  let selectedLinesGutterBackgroundColor: UIColor = .clear

  let invisibleCharactersColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.7)

  let pageGuideHairlineColor: UIColor = .tomorrow.foreground
  let pageGuideBackgroundColor: UIColor = .tomorrow.currentLine

  let markedTextBackgroundColor: UIColor = .tomorrow.foreground.withAlphaComponent(0.1)
  let markedTextBackgroundCornerRadius: CGFloat = 4

  func textColor(for rawHighlightName: String) -> UIColor? {
    guard let highlightName = HighlightName(rawHighlightName) else {
      return nil
    }
    switch highlightName {
    case .comment:
      return .tomorrow.comment
    case .operator, .punctuation:
      return .tomorrow.foreground.withAlphaComponent(0.75)
    case .property, .variableParameter:
      return .tomorrow.aqua
    case .function:
      return .tomorrow.blue
    case .string:
      return .tomorrow.green
    case .number:
      return .tomorrow.orange
    case .keyword:
      return .tomorrow.purple
    case .variableBuiltin, .variable:
      return .tomorrow.red
    }
  }

  func fontTraits(for rawHighlightName: String) -> FontTraits {
    if let highlightName = HighlightName(rawHighlightName), highlightName == .keyword {
      return .bold
    } else {
      return []
    }
  }
}
