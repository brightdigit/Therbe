// Site.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Foundation

public struct Site {
  public let title: String
  public let logoUrl: URL
  public let id: UUID
  public let domainName: String

  public var documentsURL: URL {
    return Directories.shared.sitesDirectoryUrl.appendingPathComponent(id.uuidString)
  }

  #if DEBUG

    public init(title: String, photoId: Int? = nil, id: UUID? = nil, domainName _: String? = nil) {
      self.title = title
      self.id = id ?? UUID()
      let photoId = photoId ?? Int.random(in: 1 ... 1000)
      logoUrl = URL(string: .init(format: "https://picsum.photos/id/%d/%d/%d", photoId, 1024, 1024))!
      domainName = title.filter {
        !$0.isWhitespace && !$0.isNewline
      }.lowercased() + ".com"
    }
  #endif
}
