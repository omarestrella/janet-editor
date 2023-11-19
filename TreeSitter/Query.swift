//
//  Query.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Foundation

public enum JanetQuery {
  public static var highlightsFileURL: URL {
    url(named: "highlights")
  }

  public static var localsFileURL: URL {
    url(named: "locals")
  }
}

private extension JanetQuery {
  static func url(named filename: String) -> URL {
    Bundle.main.url(forResource: filename, withExtension: "scm")!
  }
}
