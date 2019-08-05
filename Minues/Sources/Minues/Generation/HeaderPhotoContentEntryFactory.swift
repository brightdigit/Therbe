// HeaderPhotoContentEntryFactory.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation
public struct HeaderPhotoContentEntryFactory: ContentEntryFactoryProtocol {
  let imageURLProvider: ImageURLProvider
  public init(imageURLProvider: ImageURLProvider? = nil) {
    self.imageURLProvider = imageURLProvider ?? PicsumPhotoURLProvider()
  }

  public func contentEntry(fromMarkdown markdown: String, withDestinationDirectory destinationURL: URL) throws -> ContentEntryProtocol {
    var foundTitle: String?
    var newMarkdown = markdown
    let results = markdown =~ "(#+)\\s(.+)"
    for result in results.reversed() {
      if markdown[result[1]].count == 1 {
        foundTitle = String(markdown[result[2]])
        newMarkdown.removeSubrange(result[0])
      } else {
        let imageAlt = markdown[result[2]]
        // let imageUrl = String(format: photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960)
        let imageUrl = imageURLProvider.imageUrl(withSize: Size(width: 1920, height: 960))
        newMarkdown.insert(contentsOf: "![\(imageAlt)](\(imageUrl))\n\n", at: result[0].lowerBound)
      }
    }

    guard let title = foundTitle else {
      throw MissingTitleError()
    }
    let maximumDistanceFromNow = 2_600_000.0 // one month from now
    let minimumDistanceFromNow = -47_500_000.0 // 1.5 years from now
    let timeInterval = TimeInterval.random(in: minimumDistanceFromNow ... maximumDistanceFromNow)
    let date = Date(timeIntervalSinceNow: timeInterval)
    let fileName = title.slugify() + ".md"
    let fileURL = destinationURL.appendingPathComponent(fileName)
    let frontMatter = FrontMatter(
      title: title,
      date: date,
      tags: ["a", "b", "c"],
      categories: ["a", "b", "c"],
      coverImage: imageURLProvider.imageUrl(withSize: Size(width: 1920, height: 960)) // URL(string: String(format: photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960))!
    )
    return ContentEntry(frontMatter: frontMatter, content: newMarkdown, url: fileURL)
  }
}
