// Sources
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/23/19.

import Foundation
// public class DownloadGenerationTask: PostGenerationTaskProtocol {
//  public func resume() {
//    task.resume()
//  }
//
//  public typealias Callback = (Result<ContentEntryProtocol, Error>) -> Void
//  typealias ContentEntryResult = Result<ContentEntryProtocol, Error>
//  var callbacks = [Callback]()
//  var result: ContentEntryResult? {
//    didSet {
//      result.map(report(result:))
//    }
//  }
//
//  func report(result: ContentEntryResult) {
//    callbacks.forEach { $0(result) }
//  }
//
//  public func completion(_ callback: @escaping Callback) {
//    callbacks.append(callback)
//    result.map(callback)
//  }
//
//  init(sourceURL: URL, destinationURL: URL, session: URLSession? = nil, factory: ContentEntryFactoryProtocol? = nil) {
//    self.destinationURL = destinationURL
//
//    let session = session ?? URLSession.shared
//    self.factory = factory ?? HeaderPhotoContentEntryFactory()
//    task = session.downloadTask(with: sourceURL, completionHandler: urlDownloaded)
//  }
//
//  let destinationURL: URL
//  let factory: ContentEntryFactoryProtocol
//  var task: URLSessionDownloadTask!
//
//  func urlDownloaded(_ url: URL?, _: URLResponse?, _ error: Error?) {
//    let urlResult = Result(value: url, error: error, noDataError: NoDataError())
//    let stringResult = urlResult.flatMap { downloadURL in
//      Result {
//        try String(contentsOf: downloadURL)
//      }
//    }
//    let entryResult = stringResult.flatMap { markdown in
//      Result {
//        try self.factory.contentEntry(fromMarkdown: markdown, withDestinationDirectory: self.destinationURL)
//      }
//    }
//
//    result = entryResult.flatMap {
//      entry in
//      Result {
//        try entry.save()
//        return entry
//      }
//    }
//  }
// }
