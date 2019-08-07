// DirectoryList.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Minues
import SwiftUI

struct DirectoryList: View {
  let siteName: String
  let dateFormatter = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()

  var processingReady: Bool {
    guard let result = result else {
      return false
    }
    guard (try? result.get()) != nil else {
      return false
    }
    return true
  }

  @State var generator: Any?
  var isGenerating: Any? {
    generator.flatMap { self.result == nil ? $0 : nil }
  }

  @State var lastError: Error? {
    didSet {
      showError = lastError != nil
    }
  }

  @State var result: ResultList<ContentEntryProtocol>? {
    didSet {
      if case let .failure(error) = result {
        self.lastError = error
      }
    }
  }

  @State var showError: Bool = false {
    didSet {
      guard !showError else {
        return
      }
      guard lastError != nil else {
        return
      }
      lastError = nil
    }
  }

  var errorText: Text? {
    return lastError.map {
      Text($0.localizedDescription)
    }
  }

  var body: some View {
    ZStack {
      // list
      emptyText
      activityView

    }.alert(isPresented: $showError, content: {
      Alert(title: Text("Error"), message: self.errorText)
    })
      .navigationBarTitle(Text("\(self.siteName) Posts"))
    /*
          .navigationBarItems(trailing: HStack {
            // Button(action: self.generate){ Text("Generate")}.disabled(isGenerating != nil)
            // Button(action: self.process) { Text("Process") }.disabled(!processingReady)
          }
     )*/
  }

  //  func process() {
//    let minues = Minues()
//
//    guard let result = self.result else {
//      return
//    }
//
//    guard let items = try? result.get() else {
//      return
//    }
//
//    let destinationDirectoryURL = URL.temporaryDirectory()
//    print(destinationDirectoryURL)
//    let group = DispatchGroup()
//
//    for item in items {
//      group.enter()
//      DispatchQueue.global().async {
//        let html = Result(catching: { try minues.run(fromEntry: item) })
//        let url = destinationDirectoryURL.appendingPathComponent(item.frontMatter.title.slugify()).appendingPathExtension("html")
//        let result = html.flatMap {
//          html in
//          Result(catching: {
//            try html.write(to: url, atomically: false, encoding: .utf8)
//          })
//        }
//        do {
//          try result.get()
//        } catch {
//          self.lastError = error
//        }
//        group.leave()
//      }
//    }
//
//    group.notify(queue: .main) {}
  //  }

  //  var list: some View {
//    let items = self.result.flatMap { try? $0.get() }
//
//    return items.map { entries in
//      List(entries.sorted(by: { (lhs, rhs) -> Bool in
//        lhs.frontMatter.date > rhs.frontMatter.date
//      }), id: \.url.lastPathComponent) { entry in
//        VStack(alignment: .leading) {
//          Text(entry.frontMatter.title)
//          Text(self.dateFormatter.string(from: entry.frontMatter.date)).font(.subheadline)
//        }
//      }
//    }
//
  //  }

  var emptyText: some View {
    let items = self.result.flatMap { try? $0.get() }.flatMap { $0.count == 0 ? $0 : nil }

    return items.map { _ in
      Text("No Items")
    }
  }

  var activityView: some View {
    return isGenerating.map { _ in
      ActivitiyIndicatorView(style: .large)
    }
  }

  //  func generate () {
//    let markdownDirectoryURL: URL
//    markdownDirectoryURL = Directories.shared.sitesDirectoryUrl.appendingPathComponent(self.siteName, isDirectory: true).appendingPathComponent("posts", isDirectory: true)
//
//    let generator = Generator.generate(20, markdownFilesAt: markdownDirectoryURL) { (result) in
//      self.result = result
//    }
//    self.generator = generator
  //  }
}

#if DEBUG
  struct DirectoryList_Previews: PreviewProvider {
    static var previews: some View {
      DirectoryList(siteName: "sample")
    }
  }
#endif
