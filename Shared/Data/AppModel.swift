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

  var isEditorFullscreen: Bool {
    activeColumn == .detailOnly
  }

  func toggleEditorFullscreen() {
    activeColumn = .doubleColumn
  }

  // MARK: Janet

  var runtime = JanetRuntime()

  func runCode(code: String) -> Janet? {
    runtime.run(source: code)
  }

  // MARK: File management
  
  internal let fileManager = FileManager()

  @Published var activeDocument: JanetDocument?
  @Published var fileTree: [FileTreeItem] = []
  
  convenience init(fileTree: [FileTreeItem]) {
    self.init()
    
    self.fileTree = fileTree
  }

  func createFile(_ contents: String, filename: String) {
    do {
      try fileManager.createFile(contents, filename: filename)
    } catch {
      print(error)
    }
  }
  
  func deleteFile(_ item: JanetDocument) {
    do {
      try fileManager.deleteFile(item)
      loadFiles()
    } catch {
      print(error)
    }
  }
  
  func deleteItem(_ item: FileTreeItem) {
    do {
      try fileManager.deleteItem(item)
    } catch {
      print(error)
    }
  }

  func loadFiles() {
    fileTree = fileManager.getFileTree()
  }
}
