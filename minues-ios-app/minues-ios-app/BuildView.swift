// BuildView.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Minues
import SwiftUI

struct BuildView: View {
  let site: Site
  let builder = Builder()
  let destinationURL: URL
  @State var result: Result<Void, Error>?

  var body: some View {
    ZStack {
      buildView
      errorView
      completedView
    }
  }

  var errorView: some View {
    self.result.flatMap {
      result -> Error? in
      if case let .failure(error) = result {
        return error
      }
      return nil
    }.map {
      Text($0.localizedDescription)
    }
  }

  var buildView: some View {
    let isProgress = result == nil ? Void.self : nil

    return isProgress.map { _ in
      Text("Building...").onAppear {
        self.builder.build(fromSourceDirectory: self.site.documentsURL, toDestinationDirectory: self.destinationURL, self.onProgress(_:), completed: self.onCompleted(_:))
      }
    }
  }

  var completedView: some View {
    self.result.flatMap {
      try? $0.get()
    }.map {
      Text("Completed")
    }
  }

  func onProgress(_: BuilderProgress) {}

  func onCompleted(_ error: Error?) {
    result = error.map { Result<Void, Error>.failure($0) } ?? Result<Void, Error>.success({}())
  }
}

#if DEBUG
  struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
      BuildView(site: Site(title: "Lorem Ipsum"), destinationURL: URL.temporaryDirectory())
    }
  }
#endif
