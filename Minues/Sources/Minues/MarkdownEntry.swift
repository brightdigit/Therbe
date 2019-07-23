//
//  File.swift
//  
//
//  Created by Leo Dion on 7/22/19.
//

import Foundation


struct MarkdownEntry {
  let frontMatter: FrontMatter
  let markdown: String
  
  var text : String {
    return """
---
\(self.frontMatter.yaml)
---
\(self.markdown.trimmingCharacters(in: .whitespacesAndNewlines))
"""
  }
}
