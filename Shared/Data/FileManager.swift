//
//  FileManager.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Disk
import Foundation

struct File: Identifiable, Hashable {
  var url: URL
  var contents: String
  
  var name: String {
    return url.lastPathComponent
  }
  
  var id: String {
    url.absoluteString
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

  func getFiles() -> [File] {
    guard let url = try? Disk.url(for: nil, in: .documents) else {
      return []
    }
    guard let fileEnumerator = systemManager.enumerator(at: url, includingPropertiesForKeys: []) else {
      return []
    }
    
    let files = fileEnumerator.compactMap { (fileURL: Any?) -> File? in
      guard let fileURL = fileURL as? URL else { return nil }
      guard let contents = try? Disk.retrieve(fileURL.lastPathComponent, from: .documents, as: String.self) else { return nil }
      return File(url: fileURL, contents: contents)
    }
    return files
  }
}
