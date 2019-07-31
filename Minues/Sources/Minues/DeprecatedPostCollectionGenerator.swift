// DeprecatedPostCollectionGenerator.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public struct Size {
  let width: Int
  let height: Int
}

extension Array: Error where Element == Error {}

public typealias ResultList<Element> = Result<[Element], [Error]>

public protocol ImageURLProvider {
  func imageUrl(withSize size: Size) -> URL
}

public struct PicsumPhotoURLProvider: ImageURLProvider {
  static let photoURLTemplate = "https://picsum.photos/id/%d/%d/%d"
  public func imageUrl(withSize _: Size) -> URL {
    return URL(string: String(format: PicsumPhotoURLProvider.photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960))!
  }
}

public protocol ContentEntryProvider {}

public protocol ContentEntryFactoryProtocol {
  func contentEntry(fromMarkdown markdown: String, withDestinationDirectory destinationURL: URL) throws -> ContentEntryProtocol
}

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

public class DownloadGenerationTask: PostGenerationTaskProtocol {
  public func resume() {
    task.resume()
  }

  public typealias Callback = (Result<ContentEntryProtocol, Error>) -> Void
  typealias ContentEntryResult = Result<ContentEntryProtocol, Error>
  var callbacks = [Callback]()
  var result: ContentEntryResult? {
    didSet {
      result.map(report(result:))
    }
  }

  func report(result: ContentEntryResult) {
    callbacks.forEach { $0(result) }
  }

  public func completion(_ callback: @escaping Callback) {
    callbacks.append(callback)
    result.map(callback)
  }

  init(sourceURL: URL, destinationURL: URL, session: URLSession? = nil, factory: ContentEntryFactoryProtocol? = nil) {
    self.destinationURL = destinationURL

    let session = session ?? URLSession.shared
    self.factory = factory ?? HeaderPhotoContentEntryFactory()
    task = session.downloadTask(with: sourceURL, completionHandler: urlDownloaded)
  }

  let destinationURL: URL
  let factory: ContentEntryFactoryProtocol
  var task: URLSessionDownloadTask!

  func urlDownloaded(_ url: URL?, _: URLResponse?, _ error: Error?) {
    let urlResult = Result(value: url, error: error, noDataError: NoDataError())
    let stringResult = urlResult.flatMap { downloadURL in
      Result {
        try String(contentsOf: downloadURL)
      }
    }
    let entryResult = stringResult.flatMap { markdown in
      Result {
        try self.factory.contentEntry(fromMarkdown: markdown, withDestinationDirectory: self.destinationURL)
      }
    }

    result = entryResult.flatMap {
      entry in
      Result {
        try entry.save()
        return entry
      }
    }
  }
}

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

public enum ContentEntryCollectionProgress {
  case progress(Float)
  case message(String)
}

public protocol PostCollectionTaskProtocol {
  mutating func completion(_ completion: @escaping (ResultList<ContentEntryProtocol>) -> Void)
  mutating func progress(_ progress: @escaping (Result<ContentEntryCollectionProgress, Error>) -> Void)
  func resume()
}

public protocol PostCollectionProviderProtocol {
  func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol
}

public protocol PostGeneratorProtocol {
  func next() -> PostGenerationTaskProtocol
}

public protocol PostGenerationTaskProtocol {
  mutating func completion(_ completion: @escaping (Result<ContentEntryProtocol, Error>) -> Void)
  func resume()
}

public class PostCollectionTask: PostCollectionTaskProtocol {
  var completions = [(ResultList<ContentEntryProtocol>) -> Void]()
  var progresses = [(Result<ContentEntryCollectionProgress, Error>) -> Void]()

  var result: ResultList<ContentEntryProtocol>? {
    didSet {
      result.map(report(result:))
    }
  }

  func report(result: ResultList<ContentEntryProtocol>) {
    completions.forEach { $0(result) }
  }

  public func completion(_ callback: @escaping (ResultList<ContentEntryProtocol>) -> Void) {
    completions.append(callback)
    result.map(callback)
  }

  public func progress(_ callback: @escaping (Result<ContentEntryCollectionProgress, Error>) -> Void) {
    progresses.append(callback)
  }

  let builder = ResultListBuilder<ContentEntryProtocol>()
  private var tasks = [PostGenerationTaskProtocol]()

  func append(_ task: PostGenerationTaskProtocol) {
    assert(builder.count == 0, "Cannot add tasks after operation has started.")
    var newTask = task
    newTask.completion(taskCompleted)
    tasks.append(newTask)
  }

  func taskCompleted(_ result: Result<ContentEntryProtocol, Error>) {
    let percent = Float(builder.count) / Float(tasks.count)
    let progress = result.map { _ in ContentEntryCollectionProgress.progress(percent) }
    progresses.forEach { $0(progress) }
    builder.append(result)
    print(percent)
    if builder.count >= tasks.count {
      self.result = builder.result
    }
  }

  public func resume() {
    tasks.forEach { $0.resume() }
  }
}

public struct PostCollectionProvider: PostCollectionProviderProtocol {
  public init() {}
  public func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol {
    let collection = PostCollectionTask()
    (1 ... count).forEach { _ in
      collection.append(generator.next())
    }

    return collection
  }
}

@available(*, deprecated, renamed: "PostCollectionGenerator")
public class DeprecatedPostCollectionGenerator {
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

  public static func generate(_ count: Int, markdownFilesAt directoryURL: URL, _ completed: @escaping (ResultList<ContentEntryProtocol>) -> Void) -> DeprecatedPostCollectionGenerator {
    let generator = DeprecatedPostCollectionGenerator(destinationURL: directoryURL, count: count, callback: completed)
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
      let entry = try DeprecatedPostCollectionGenerator.write(entryResult)
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
