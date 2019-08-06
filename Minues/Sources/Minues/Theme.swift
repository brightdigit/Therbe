// Theme.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

public struct Theme: Hashable {
  public let title: String
  public let directoryURL: URL

  public init?(configURL: URL) {
    let minues = Minues()
    guard let config = try? minues.yaml(fromURL: configURL) else {
      return nil
    }

    guard let title = config["title"] as? String else {
      return nil
    }
    self.title = title
    directoryURL = configURL.deletingLastPathComponent()
  }
}
