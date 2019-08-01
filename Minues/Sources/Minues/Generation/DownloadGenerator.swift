// DownloadGenerator.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation
import Combine

struct LoremMarkdownum {
  static let url = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!
}
@available(iOS 13.0, *)
public struct DownloadGenerator<FactoryType : ContentEntryFactoryProtocol, PublisherType : Publisher, ContentEntryType>  where FactoryType.ContentEntryType == ContentEntryType, PublisherType.Output == ContentEntryType, PublisherType.Failure == Error {
  // fromURL sourceURL: URL, toURL destinationURL: URL,
  func publisher(usingFactory factory: FactoryType, withSession session: URLSession? = nil) -> AnyPublisher<ContentEntryType, Error> {
    let sourceURL = self.downloadURLGenerator()
    let session = session ?? URLSession.shared
    let publisher = session.dataTaskPublisher(for: sourceURL).tryMap{
      guard let text = String(data: $0.data, encoding: .utf8) else {
        throw MinuesError.invalidData
      }
      return text
    }.tryMap{
      try factory.saveContentEntry(fromMarkdown: $0, withDestinationDirectory: self.destinationUrl)
    }
    return publisher.eraseToAnyPublisher()
  }
//  public func next() -> PostGenerationTaskProtocol {
//    return DownloadGenerationTask(sourceURL: downloadURLGenerator(), destinationURL: destinationUrl)
//  }

  let destinationUrl: URL
  let downloadURLGenerator: () -> URL
  let imageUrlProvider: ImageURLProvider?


  static func staticGenerator(withUrl url: URL) -> (() -> URL) {
    return {
      url
    }
  }

  public init(destinationUrl: URL, downloadURLGenerator: (() -> URL)? = nil, imageUrlProvider: ImageURLProvider? = nil) {
    self.destinationUrl = destinationUrl
    self.downloadURLGenerator = downloadURLGenerator ?? DownloadGenerator.staticGenerator(withUrl: LoremMarkdownum.url)
    self.imageUrlProvider = imageUrlProvider
  }
}
