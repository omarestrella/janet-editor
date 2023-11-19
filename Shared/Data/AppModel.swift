//
//  Store.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Foundation
import SwiftUI

class AppModel: ObservableObject {
  @Published var activeColumn: NavigationSplitViewVisibility = .doubleColumn

  internal let fileManager = FileManager()

  var isEditorFullscreen: Bool {
    activeColumn == .detailOnly
  }

  func toggleEditorFullscreen() {
    activeColumn = .doubleColumn
  }

  // MARK: Janet

  @Published var results: [Janet] = []

  var vm = JanetVM()

  func runCode(code: String) {
    DispatchQueue.global().async {
      guard let result = self.vm.run(source: code) else { return }

      DispatchQueue.main.sync {
        self.results.append(result)
      }
    }
  }

  // MARK: File management

  @Published var activeFile: File?

  func createFile(_ contents: String, filename: String) {
    do {
      try fileManager.createFile(contents, filename: filename)
    } catch {
      print(error)
    }
  }

  func getFiles() -> [File] {
    fileManager.getFiles()
  }
}
