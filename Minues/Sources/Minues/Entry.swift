// Entry.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public struct Entry {
  public let frontMatter: FrontMatter
  public let content: String
  public let url: URL

  var text: String {
    return """
    ---
    \(frontMatter.yaml)
    ---
    \(content.trimmingCharacters(in: .whitespacesAndNewlines))
    """
  }
}
