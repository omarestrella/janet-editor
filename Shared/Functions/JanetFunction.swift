//
//  JanetFunction.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 1/5/24.
//

import Foundation

public protocol JanetFunction {
  var name: String { get }
  var documentation: String { get }
  
  func run()
}
