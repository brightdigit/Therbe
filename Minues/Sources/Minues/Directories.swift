// Directories.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Foundation

public struct Directories {
  // swiftlint:disable:next force_try
  public static let shared = try! Directories()
  public let documentDirectoryUrl: URL
  public let sitesDirectoryUrl: URL
  init(fromUrlFor _: FileManager.SearchPathDirectory? = .documentDirectory, in _: FileManager.SearchPathDomainMask = .userDomainMask) throws {
    let documentDirectoryUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    guard let documentDirURL = documentDirectoryUrls.first else {
      throw NoDocumentDirectoryError()
    }
    documentDirectoryUrl = documentDirURL
    sitesDirectoryUrl = documentDirectoryUrl.appendingPathComponent("sites", isDirectory: true)
  }
}
