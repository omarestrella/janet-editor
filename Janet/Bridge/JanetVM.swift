//
//  JanetBridge.swift
//  JanetBridge
//
//  Created by Omar Estrella on 6/9/22.
//

import Foundation

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
    case .Number(number: let num):
      return num.debugDescription
    case .String(string: let str):
      return str
    case .Keyword(keyword: let str):
      return ":\(str)"
    case .Tuple(tuple: let tup):
      return "[\(tup.map({ $0.debugDescription }).joined(separator: ", "))]"
    case .Array(array: let arr):
      return "[\(arr.map({ $0.debugDescription }).joined(separator: ", "))]"
    case .Struct(struct: let map):
      return "\(map)"
    }
  }
  
}

public class JanetVM {
  var env: UnsafeMutablePointer<JanetTable>

  init() {
    janet_init()
    env = janet_core_env(nil)
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
        if (key == .Nil) {
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

  private func callJanetFunction(fn: UnsafeMutablePointer<JanetFunction>, argc: Int32, argv: UnsafePointer<CJanet>, out: UnsafeMutablePointer<CJanet>) -> Bool {
    var fiber: UnsafeMutablePointer<JanetFiber>?
    let result = janet_pcall(fn, argc, argv, out, &fiber)
    if result == JANET_SIGNAL_OK {
      return true
    } else {
      janet_stacktrace(fiber, out.pointee)
      return false
    }
  }

  public func run(source: String) -> Janet? {
    janet_init()
    let env = janet_core_env(nil)
    
    var result = janet_wrap_nil()

    let cSource = source.cString(using: String.defaultCStringEncoding)
    let cMain = "main".cString(using: String.defaultCStringEncoding)
    janet_dostring(env, cSource, cMain, &result)

    let runResult = getSwiftValue(&result)

    janet_deinit()

    return runResult
  }
}
