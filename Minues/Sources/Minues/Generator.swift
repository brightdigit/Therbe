// Generator.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

extension Array: Error where Element == Error {}

public typealias ResultList<Element> = Result<[Element], [Error]>

public class Generator {
  let destinationURL: URL
  let count: Int
  let callback: (ResultList<ContentEntryProtocol>) -> Void
  let group = DispatchGroup()
  var tasks: [URLSessionDownloadTask]!
  let resultListBuilder = ResultListBuilder<ContentEntryProtocol>()

  let photoURLTemplate = "https://picsum.photos/id/%d/%d/%d"
  let markdownUrl = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!

  var state: URLSessionTask.State {
    var currentState: URLSessionTask.State?
    for task in tasks {
      switch task.state {
      case .running:
        return .running
      case .canceling:
        return .canceling
      default:
        if task.state == currentState || currentState == nil {
          currentState = task.state
        } else {
          return .running
        }
      }
    }
    return currentState ?? .suspended
  }

  init(destinationURL: URL, count: Int, callback: @escaping (ResultList<ContentEntryProtocol>) -> Void) {
    self.destinationURL = destinationURL
    self.count = count
    self.callback = callback

    tasks = (1 ... count).map { _ in
      URLSession.shared.downloadTask(with: markdownUrl, completionHandler: self.downloadCompletedAtURL(url:withResponse:andError:))
    }
  }

  public static func generate(_ count: Int, markdownFilesAt directoryURL: URL, _ completed: @escaping (ResultList<ContentEntryProtocol>) -> Void) -> Generator {
    let generator = Generator(destinationURL: directoryURL, count: count, callback: completed)
    generator.begin()
    return generator
  }

  public func begin() {
    for task in tasks {
      group.enter()
      DispatchQueue.global().async {
        task.resume()
      }
    }
    group.notify(queue: .main) {
      self.callback(self.resultListBuilder.result)
    }
  }

  func downloadCompletedAtURL(url: URL?, withResponse _: URLResponse?, andError error: Error?) {
    let urlResult = Result(value: url, error: error, noDataError: NoDataError())
    let stringResult = urlResult.flatMap { downloadURL in
      Result {
        try String(contentsOf: downloadURL)
      }
    }
    let entryResult = stringResult.flatMap { markdown in
      Result { () -> ContentEntryProtocol in
        var foundTitle: String?
        var newMarkdown = markdown
        let results = markdown =~ "(#+)\\s(.+)"
        for result in results.reversed() {
          if markdown[result[1]].count == 1 {
            foundTitle = String(markdown[result[2]])
            newMarkdown.removeSubrange(result[0])
          } else {
            let imageAlt = markdown[result[2]]
            let imageUrl = String(format: photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960)
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
        let fileURL = self.destinationURL.appendingPathComponent(fileName)
        let frontMatter = FrontMatter(
          title: title,
          date: date,
          tags: ["a", "b", "c"],
          categories: ["a", "b", "c"],
          coverImage: URL(string: String(format: photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960))!
        )
        return ContentEntry(frontMatter: frontMatter, content: newMarkdown, url: fileURL)
      }
    }
    do {
      let entry = try Generator.write(entryResult)
      resultListBuilder.append(entry)
    } catch {
      resultListBuilder.append(error)
    }
    group.leave()
  }

  private static func write(_ entryResult: Result<ContentEntryProtocol, Error>) throws -> ContentEntryProtocol {
    let entry: ContentEntryProtocol
    entry = try entryResult.get()

    try entry.text.write(to: entry.url, atomically: false, encoding: .utf8)
    return entry
  }
}
