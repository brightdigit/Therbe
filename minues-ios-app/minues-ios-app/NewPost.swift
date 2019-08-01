// NewPost.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Combine
import Minues
import SwiftUI

class ContentEntryBindableObject: Identifiable, ObservableObject {
  init(publisher: AnyPublisher<ContentEntry, Error>) {
    self.publisher = publisher
    // publisher.subscribe(self.objectWillChange)
    publisher.subscribe(subject)
  }

  let publisher: AnyPublisher<ContentEntry, Error>
  var subject = PassthroughSubject<ContentEntry, Error>()

  var objectWillChange = ObservableObjectPublisher()
}

struct NewPost: View {
  var body: some View {
    Text("\(contentEntry.debugDescription ?? "empty")").onReceive(self.publisher) { result in
      self.contentEntry = result
    }
  }

  @State var contentEntry: Result<ContentEntry, Error>? = nil

  var publisher: AnyPublisher<Result<ContentEntry, Error>?, Never> {
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
    let assignment = publisher.receive(on: DispatchQueue.main).assign(to: \NewPost.contentEntry, on: self)

    return publisher.eraseToAnyPublisher()
  }
}

#if DEBUG
  struct NewPost_Previews: PreviewProvider {
    static var previews: some View {
      NewPost()
    }
  }
#endif
