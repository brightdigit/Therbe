// URL.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

public extension URL {
  func pathComponentIndex(commonWith base: URL) -> Int? {
    // Ensure that both URLs represent files:
    guard isFileURL, base.isFileURL else {
      return nil
    }

    // Remove/replace "." and "..", make paths absolute:
    let destComponents = standardized.pathComponents
    let baseComponents = base.standardized.pathComponents

    // Find number of common path components:
    var index = 0
    while index < destComponents.count, index < baseComponents.count,
      destComponents[index] == baseComponents[index] {
      index += 1
    }

    return index

    // Build relative path:
    //    var relComponents = Array(repeating: "..", count: baseComponents.count - i)
    //    relComponents.append(contentsOf: destComponents[i...])
    //    return relComponents.joined(separator: "/")
  }

  static func temporaryDirectory() -> URL {
    return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
  }
}
