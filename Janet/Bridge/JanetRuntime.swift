//
//  JanetBridge.swift
//  JanetBridge
//
//  Created by Omar Estrella on 6/9/22.
//

import Foundation
import UIKit

public enum Janet: Hashable, CustomDebugStringConvertible {
  case Nil
  case Number(number: Double)
  case String(string: String)
  case Keyword(keyword: String)
  case Tuple(tuple: [Janet])
  case Array(array: [Janet])
  case Struct(struct: [Janet: Janet])

  public var debugDescription: String {
    switch self {
    case .Nil:
      return "NULL"
    case let .Number(number: num):
      return num.debugDescription
    case let .String(string: str):
      return str
    case let .Keyword(keyword: str):
      return ":\(str)"
    case let .Tuple(tuple: tup):
      return "[\(tup.map { $0.debugDescription }.joined(separator: ", "))]"
    case let .Array(array: arr):
      return "[\(arr.map { $0.debugDescription }.joined(separator: ", "))]"
    case let .Struct(struct: map):
      return "\(map)"
    }
  }
}

class FunctionRegistryEntry {
  var function: JanetFunction

  var name: [CChar] = []
  var documentation: [CChar] = []

  init(function: JanetFunction) {
    self.function = function
    if let name = function.name.cString(using: .utf8) {
      self.name = name
    }
    if let documentation = function.documentation.cString(using: .utf8) {
      self.documentation = documentation
    }
  }

  func run() {
    function.run()
  }
}

func makePointer(_ obj: FunctionRegistryEntry) -> UnsafeMutableRawPointer {
  return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func getClass(_ ptr: UnsafeMutableRawPointer) -> FunctionRegistryEntry? {
  return Unmanaged.fromOpaque(ptr).takeUnretainedValue()
}

enum Callbacks {
  static var registry: [String: FunctionEntryCallback] = [:]
}

public class JanetRuntime {
  var env: UnsafeMutablePointer<JanetTable>
//  var functionRegistry: [String: FunctionRegistryEntry] = [:]

  init() {
    janet_init()
    guard let env = janet_core_env(nil) else {
      print("Couldnt build janet env")
      exit(0)
    }
    self.env = env
  }

  deinit {
    janet_deinit()
  }

  func getSwiftValue(_ janet: inout CJanet) -> Janet? {
    let type = janet_type(janet)
    switch type {
    case JANET_NIL:
      return .Nil
    case JANET_NUMBER:
      return .Number(number: janet_unwrap_number(janet))
    case JANET_KEYWORD:
      guard let keyword = janet_unwrap_keyword(janet) else {
        return nil
      }
      return .Keyword(keyword: String(cString: keyword))
    case JANET_STRING:
      guard let string = janet_unwrap_string(janet) else {
        return nil
      }
      return .String(string: String(cString: string))
    case JANET_TUPLE:
      let size = janet_length(janet)
      let arr: [Janet] = stride(from: 0, to: Double(size), by: 1).compactMap { idx in
        var t = janet_in(janet, janet_wrap_number(idx))
        return self.getSwiftValue(&t)
      }
      return .Tuple(tuple: arr)
    case JANET_ARRAY:
      guard let array = janet_unwrap_array(janet) else {
        return nil
      }
      let size = array.pointee.count
      let arr: [Janet] = stride(from: 0, to: Double(size), by: 1).compactMap { idx in
        var t = janet_get(janet, janet_wrap_number(idx))
        return self.getSwiftValue(&t)
      }
      return .Array(array: arr)
    case JANET_STRUCT:
      guard let jStruct = janet_unwrap_struct(janet) else {
        return nil
      }

      guard let head = janet_struct_head(jStruct) else { return nil }

      let ptr = jStruct
      var map: [Janet: Janet] = [:]

      stride(from: 0, to: Int(head.pointee.length) * 2, by: 1).forEach { idx in
        var keyPtr = ptr[idx].key
        var valuePtr = ptr[idx].value
        guard let key = getSwiftValue(&keyPtr) else { return }
        // I'm not sure why we get so many null keys. The struct memory layout is odd.
        if key == .Nil {
          return
        }
        let value = getSwiftValue(&valuePtr) ?? .Nil
        map[key] = value
      }

      return .Struct(struct: map)
    default:
      print("Got result I didnt expect", type)
      return nil
    }
  }

  public func registerFunction(_ janetFunction: JanetFunction) {
    var entry = FunctionRegistryEntry(function: janetFunction)
//    functionRegistry.updateValue(entry, forKey: janetFunction.name)
//    var name = janetFunction.name.utf8CString.withUnsafeBufferPointer { $0.baseAddress }
//    Callbacks.registry[janetFunction.name] =

    let callback = initializeCallback(&entry.name, makePointer(entry)) { name, entryPtr in
      if let entryPtr {
        let entry = getClass(entryPtr)
        entry?.run()
      }
    }
    
    let cfun: JanetCFunction = { argc, argv in
      return janet_wrap_nil()
    }

    let reg: [JanetReg] = [
      .init(name: &entry.name, cfun: cfun, documentation: &entry.documentation),
      .init(name: nil, cfun: nil, documentation: nil),
    ]
    janet_cfuns(env, nil, reg)
  }

  let fnName = "alert".cString(using: .utf8)

  public func run(source: String) -> Janet? {
    var result = janet_wrap_nil()

    let cSource = source.cString(using: String.defaultCStringEncoding)
    let cMain = "main".cString(using: String.defaultCStringEncoding)
    janet_dostring(env, cSource, cMain, &result)

    let runResult = getSwiftValue(&result)

    return runResult
  }
}

// let reg: [JanetReg] = [
//  .init(name: fnName, cfun: { argc, argv in
//    janet_fixarity(argc, 2)
//    let title = String(cString: janet_unwrap_string(argv![0]))
//    let message = String(cString: janet_unwrap_string(argv![1]))
//    let window = UIApplication.shared.windows[1]
//    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//    alert.addAction(.init(title: "close", style: .default, handler: { _ in
//      alert.dismiss(animated: true)
//    }))
//    window.rootViewController?.present(alert, animated: true)
//    return janet_wrap_nil()
//  }, documentation: "(alert) \n\nshows an alert".cString(using: .utf8)),
//  .init(name: nil, cfun: nil, documentation: nil)
// ]
// janet_cfuns(env, nil, reg)
