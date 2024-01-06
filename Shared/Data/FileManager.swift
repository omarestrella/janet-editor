//
//  FileManager.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Disk
import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum DocumentError: Error {
  case ReadError
  case WriteError
}

enum FSItemType {
  case File
  case Folder
}

class JanetDocument: Identifiable {
  let id = UUID()

  var url: URL?
  var children: [JanetDocument]?
  var contents = ""

  init(contents: String) {
    self.contents = contents
  }

  init(contents: String, url: URL) {
    self.contents = contents
    self.url = url
  }

  var name: String {
    return url?.lastPathComponent ?? "(No Name)"
  }

  var type: FSItemType {
    if children != nil {
      return .Folder
    }
    return .File
  }
}

class FileTreeItem: Identifiable {
  let id = UUID()
  var children: [FileTreeItem]?

  let name: String
  var url: URL?
  var document: JanetDocument?

  init(name: String, url: URL? = nil) {
    self.name = name
    self.url = url
  }

  init(name: String, children: [FileTreeItem], url: URL? = nil) {
    self.name = name
    self.children = children
    self.url = url
  }

  init(name: String, document: JanetDocument, url: URL? = nil) {
    self.name = name
    self.document = document
    self.url = url
  }

  var type: FSItemType {
    if document != nil {
      return .File
    }
    return .Folder
  }
}

struct FileManager {
  let systemManager = Foundation.FileManager()

  init() {
    print("Storing files: \(String(describing: try? Disk.url(for: nil, in: .documents).absoluteString))")
  }

  func createFile(_ contents: String, filename: String) throws {
    try Disk.save(contents, to: .documents, as: filename)
  }

  func deleteFile(_ item: JanetDocument) throws {
    if let url = item.url {
      try Disk.remove(url)
    }
  }

  func deleteItem(_ item: FileTreeItem) throws {
    if let url = item.url {
      try Disk.remove(url)
    }
  }

  func getFileTree() -> [FileTreeItem] {
    guard let url = try? Disk.url(for: nil, in: .documents) else {
      return []
    }
    guard let fileEnumerator = systemManager.enumerator(at: url, includingPropertiesForKeys: []) else {
      return []
    }

    var folders = [FileTreeItem]()

    let files = fileEnumerator.compactMap { (fileURL: Any?) -> FileTreeItem? in
      guard let fileURL = fileURL as? URL else { return nil }

      if fileURL.hasDirectoryPath {
        let item = FileTreeItem(name: fileURL.lastPathComponent, children: [], url: fileURL)
        folders.append(item)
        return item
      } else {
        guard let data = try? Data(contentsOf: fileURL) else {
          return nil
        }
        let document = JanetDocument(contents: String(data: data, encoding: .utf8) ?? "", url: fileURL)
        let item = FileTreeItem(name: fileURL.lastPathComponent, document: document, url: fileURL)
        let folderName = fileURL.deletingLastPathComponent().lastPathComponent
        if let folder = folders.first(where: { $0.name == folderName }) {
          folder.children?.append(item)
          return nil
        }
        return item
      }
    }
    return files
  }
}
