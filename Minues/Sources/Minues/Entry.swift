//
//  File.swift
//  
//
//  Created by Leo Dion on 7/22/19.
//

import Foundation


public struct Entry {
  public let frontMatter: FrontMatter
  public let content: String
  public let url : URL
  
  var text : String {
    return """
---
\(self.frontMatter.yaml)
---
\(self.content.trimmingCharacters(in: .whitespacesAndNewlines))
"""
  }
}
