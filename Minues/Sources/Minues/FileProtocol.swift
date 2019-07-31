// FileProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public protocol FileProtocol {
  var relativePath: String { get }
  var name: String { get }
  func contents() throws -> String
}

// struct Entry {
//  let url : URL
//  let baseUrl : URL
// }

@available(*, deprecated, renamed: "FileProtocol")
protocol LayoutProtocol {
  var relativePath: String { get }
  var name: String { get }
  func contents() throws -> String
}

@available(*, deprecated, renamed: "FileProtocol")
protocol IncludeProtocol {
  var relativePath: String { get }
  var name: String { get }
  func contents() throws -> String
}

@available(*, deprecated, renamed: "FileProtocol")
protocol ContentProtocol {
  var relativePath: String { get }

  var name: String { get }
  var isPost: Bool { get }
  func contents() throws -> String
  var isMarkdown: Bool { get }
}

@available(*, deprecated, renamed: "FileProtocol")
protocol StylesheetProtocol {
  func contents() throws -> String
  var relativePath: String { get }
}
