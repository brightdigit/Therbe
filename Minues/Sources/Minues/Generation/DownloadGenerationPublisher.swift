// Sources
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/23/19.

import Combine
import Foundation
//
// @available(iOS 13.0, macOS 10.15, *)
// public struct DownloadGenerationPublisher<FactoryType : ContentEntryFactoryProtocol, PublisherType : Publisher, ContentEntryType>
// where FactoryType.ContentEntryType == ContentEntryType, PublisherType.Output == ContentEntryType, PublisherType.Failure == Error {
//
//
//
//
//  init(sourceURL: URL, destinationURL: URL, session: URLSession? = nil, factory: FactoryType) {
//    self.destinationURL = destinationURL
//
//    let session = session ?? URLSession.shared
//    self.factory = factory
//    let publisher = session.dataTaskPublisher(for: sourceURL).tryMap(stringDecodeFromData).tryMap(contentEntryFromString(_:))
//    self.publisher = publisher.eraseToAnyPublisher()
//    //publisher.receive(subscriber: self)

//  }
//
//  func publisher(fromURL sourceURL: URL, toURL destinationURL: URL, usingFactory factory: FactoryType, withSession session: URLSession? = nil) -> AnyPublisher<ContentEntryType, Error> {
//    let session = session ?? URLSession.shared
//    let publisher = session.dataTaskPublisher(for: sourceURL).tryMap{
//      (data) in
//      guard let text = String(data: data, encoding: .utf8) else {
//        throw MinuesError.invalidData
//      }
//      return text
//    }.tryMap{
//      try self.contentEntryFromString($0)
//    }
//    return publisher.eraseToAnyPublisher()
//  }
//
//  // var task: URLSessionDownloadTask!
////
////  static func stringDecodeFromData(_ data: Data) throws -> String {
////    guard let text = String(data: data, encoding: .utf8) else {
////      throw MinuesError.invalidData
////    }
////    return text
////  }
//
// }
