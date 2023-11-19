//
//  EditorView.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Foundation
import Runestone
import SwiftUI

struct FileEditor: UIViewRepresentable {
  let state: TextViewState
  
  let theme = TomorrowTheme()

  @Binding var text: String

  init(text: Binding<String>) {
    _text = text

    let highlightsQuery = TreeSitterLanguage.Query(contentsOf: JanetQuery.highlightsFileURL)
    let language = TreeSitterLanguage(tree_sitter_janet(), highlightsQuery: highlightsQuery)
    state = TextViewState(text: text.wrappedValue, theme: theme, language: language)
  }

  func makeCoordinator() -> TextViewCoordinator {
    TextViewCoordinator(self)
  }

  func makeUIView(context: Context) -> Runestone.TextView {
    let textView = TextView()
    textView.showLineNumbers = true
    textView.showSpaces = true
    textView.alwaysBounceVertical = true
    
    textView.keyboardDismissMode = .onDrag

    textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

    textView.autocorrectionType = .no
    textView.autocapitalizationType = .none
    textView.smartDashesType = .no
    textView.smartQuotesType = .no
    textView.smartInsertDeleteType = .no

    textView.indentStrategy = .space(length: 2)

    textView.editorDelegate = context.coordinator
    textView.setState(state)

    textView.backgroundColor = theme.backgroundColor
    textView.insertionPointColor = theme.textColor
    textView.selectionBarColor = theme.textColor
    textView.selectionHighlightColor = theme.textColor.withAlphaComponent(0.2)

    return textView
  }

  func updateUIView(_ textView: TextView, context: Context) {
    textView.text = self.text
  }

  final class TextViewCoordinator: NSObject, TextViewDelegate {
    let parent: FileEditor

    init(_ parent: FileEditor) {
      self.parent = parent
    }

    func textViewDidChange(_ textView: TextView) {
      parent.text = textView.text
    }
  }
}

struct EditorView: View {
  @EnvironmentObject var appModel: AppModel
  
  @State var file: File

  @State var editorText = ""

  var body: some View {
    HStack {
      FileEditor(text: $editorText)
    }
    .onAppear {
      editorText = file.contents
    }
    .toolbar(content: {
      ToolbarItem(placement: .principal, content: {
        Text(file.name)
      })

      ToolbarItem(placement: .primaryAction, content: {
        Button(action: {
          appModel.runCode(code: editorText)
        }, label: {
          Label("Run", systemImage: "play.fill")
        })
      })
    })
  }
}
