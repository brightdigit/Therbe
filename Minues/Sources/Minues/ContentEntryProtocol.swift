// ContentEntryProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public protocol ContentEntryProtocol {
  var text: String { get }
  var url: URL { get }
}

extension ContentEntryProtocol {
  func save(atomically: Bool = false, encoding: String.Encoding = .utf8) throws {
    try text.write(to: url, atomically: atomically, encoding: encoding)
  }
}

public struct ContentEntry: ContentEntryProtocol {
  public let frontMatter: FrontMatter
  public let content: String
  public let url: URL

  public var text: String {
    return """
    ---
    \(frontMatter.yaml)
    ---
    \(content.trimmingCharacters(in: .whitespacesAndNewlines))
    """
  }
}
