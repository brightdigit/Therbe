// NewPost.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Combine
import Minues
import SwiftUI

typealias ContentEntryPublisher = AnyPublisher<Result<ContentEntry, Error>?, Never>

class ContentEntryBindableObject: Identifiable, ObservableObject {
  init(publisher: ContentEntryPublisher) {
    self.publisher = publisher
    publisher.receive(on: DispatchQueue.main).assign(to: \ContentEntryBindableObject.result, on: self)
    // publisher.subscribe(self.objectWillChange)
    // publisher.subscribe(subject)
  }

  let publisher: ContentEntryPublisher
  @Published var result: Result<ContentEntry, Error>? = nil {
    willSet {
      objectWillChange.send()
    }
  }
}

struct NewPost: View {
  var body: some View {
    Text("\(postData.result.debugDescription ?? "empty")")
  }

  @ObservedObject var postData: ContentEntryBindableObject

//  var publisher: AnyPublisher<Result<ContentEntry, Error>?, Never> {
//    let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//    let generator = DownloadGenerator(destinationUrl: temporaryURL, factory: HeaderPhotoContentEntryFactory())
//    let publisher = generator.publisher().map {
//      Result<ContentEntry, Error>.success($0)
//    }.catch { error in
//      Just(Result<ContentEntry, Error>.failure(error))
//    }.map {
//      result -> Result<ContentEntry, Error>? in
//      result
//    }
//    let assignment = publisher.receive(on: DispatchQueue.main).assign(to: \NewPost.contentEntry, on: self)
//
//    return publisher.eraseToAnyPublisher()
//  }
  init() {
    let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    let generator = DownloadGenerator(destinationUrl: temporaryURL, factory: HeaderPhotoContentEntryFactory())
    let publisher = generator.publisher().map {
      Result<ContentEntry, Error>.success($0)
    }.catch { error in
      Just(Result<ContentEntry, Error>.failure(error))
    }.map {
      result -> Result<ContentEntry, Error>? in
      result
    }
    postData = ContentEntryBindableObject(publisher: publisher.eraseToAnyPublisher())
  }
}

#if DEBUG
  struct NewPost_Previews: PreviewProvider {
    static var previews: some View {
      NewPost()
    }
  }
#endif
