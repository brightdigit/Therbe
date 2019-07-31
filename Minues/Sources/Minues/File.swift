//
//  File.swift
//  
//
//  Created by Leo Dion on 7/31/19.
//

import Foundation

public protocol EntryProtocol {

  var relativePath : String { get }
  var name : String { get }
  func contents() throws -> String
}

//struct Entry {
//  let url : URL
//  let baseUrl : URL
//}

@available(*, deprecated, renamed: "EntryProtocol")
protocol LayoutProtocol {
  var relativePath : String { get }
  var name : String { get }
  func contents() throws -> String
}

@available(*, deprecated, renamed: "EntryProtocol")
protocol IncludeProtocol {
  var relativePath : String { get }
  var name : String { get }
  func contents() throws -> String
}

@available(*, deprecated, renamed: "EntryProtocol")
protocol ContentProtocol {
  
  var relativePath : String { get }
  
  var name: String { get }
  var isPost : Bool { get }
  func contents() throws -> String
  var isMarkdown : Bool  { get }
}
