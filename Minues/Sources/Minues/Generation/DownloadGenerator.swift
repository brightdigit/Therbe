// DownloadGenerator.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation
public struct DownloadGenerator: PostGeneratorProtocol {
  public func next() -> PostGenerationTaskProtocol {
    return DownloadGenerationTask(sourceURL: downloadURLGenerator(), destinationURL: destinationUrl)
  }

  let destinationUrl: URL
  let downloadURLGenerator: () -> URL
  let imageUrlProvider: ImageURLProvider?

  static let loremMarkdownum = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!

  static func staticGenerator(withUrl url: URL) -> (() -> URL) {
    return {
      url
    }
  }

  public init(destinationUrl: URL, downloadURLGenerator: (() -> URL)? = nil, imageUrlProvider: ImageURLProvider? = nil) {
    self.destinationUrl = destinationUrl
    self.downloadURLGenerator = downloadURLGenerator ?? DownloadGenerator.staticGenerator(withUrl: DownloadGenerator.loremMarkdownum)
    self.imageUrlProvider = imageUrlProvider
  }
}
