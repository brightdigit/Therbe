// Sources
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/23/19.

import Combine
import Foundation

struct LoremMarkdownum {
  static let url = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!
}

@available(iOS 13.0, *)
public struct DownloadGenerator<
  FactoryType: ContentEntryFactoryProtocol,
  ContentEntryType
>
  where FactoryType.ContentEntryType == ContentEntryType {
  // fromURL sourceURL: URL, toURL destinationURL: URL,
  public func publisher(withSession session: URLSession? = nil) -> AnyPublisher<ContentEntryType, Error> {
    let sourceURL = downloadURLGenerator()
    let session = session ?? URLSession.shared
    let publisher = session.dataTaskPublisher(for: sourceURL).tryMap {
      guard let text = String(data: $0.data, encoding: .utf8) else {
        throw MinuesError.invalidData
      }
      return text
    }.tryMap {
      try self.factory.saveContentEntry(fromMarkdown: $0, withDestinationDirectory: self.destinationUrl)
    }
    return publisher.eraseToAnyPublisher()
  }

//  public func next() -> PostGenerationTaskProtocol {
//    return DownloadGenerationTask(sourceURL: downloadURLGenerator(), destinationURL: destinationUrl)
//  }

  let destinationUrl: URL
  let downloadURLGenerator: () -> URL
  let imageUrlProvider: ImageURLProvider?
  let factory: FactoryType

  static func staticGenerator(withUrl url: URL) -> (() -> URL) {
    return {
      url
    }
  }

  public init(destinationUrl: URL, factory: FactoryType, downloadURLGenerator: (() -> URL)? = nil, imageUrlProvider: ImageURLProvider? = nil) {
    self.destinationUrl = destinationUrl
    self.downloadURLGenerator = downloadURLGenerator ?? DownloadGenerator.staticGenerator(withUrl: LoremMarkdownum.url)
    self.imageUrlProvider = imageUrlProvider
    self.factory = factory
  }
}
