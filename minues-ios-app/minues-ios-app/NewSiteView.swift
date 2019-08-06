// NewSiteView.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Minues
import Promises
import SwiftUI

struct NewSiteView: View {
  var readyForBuild: Bool {
    return !siteTitle.isEmpty
  }

  @State var siteBuiling = false
  @State var siteTitle: String = ""
  @State var pickedThemeIndex = 0
  @State var themes: Result<[Theme], Error>? = nil
  let loadingDirectoryUrl: URL = Bundle.main.url(forResource: "themes", withExtension: nil)!
  var body: some View {
    ZStack {
      inputView
      errorView
      busyView.onAppear(perform: self.beginLoad)
    }
  }

  func beginLoad() {
    var themeConfigs = [URL]()
    guard let enumerator = FileManager.default.enumerator(at: self.loadingDirectoryUrl, includingPropertiesForKeys: nil) else {
      return
    }
    while let url = enumerator.nextObject() as? URL {
      if url.lastPathComponent == "_config.yml" {
        themeConfigs.append(url)
      }
    }
    themes = .success(themeConfigs.compactMap(Theme.init(configURL:)))
  }

  var busyView: some View {
    let loading: Void? = (self.themes == nil || self.siteBuiling) ? Void() : nil
    return loading.map {
      ActivitiyIndicatorView(style: .large)
    }
  }

  var inputView: some View {
    self.themes.flatMap {
      (try? $0.get()).map {
        themes in
        Form {
          Section {
            TextField("Name", text: $siteTitle)
          }
          Section {
            Picker(selection: $pickedThemeIndex, label: Text("Theme")) {
              ForEach(0 ..< themes.count) {
                Text(themes[$0].title).tag($0)
              }
            }
          }
          Section {
            Button(action: self.beginBuild) {
              Text("Build")
            }.disabled(!self.readyForBuild)
          }
        }
      }
    }
  }

  func beginBuild() {
    siteBuiling = true
    let minues = Minues()

    let chosenTheme = themes.flatMap { try? $0.get() }.flatMap { $0[self.pickedThemeIndex] }

    guard let theme = chosenTheme else {
      return
    }
    let site = Site(title: siteTitle)

    minues.setupSite(site, withTheme: theme).then { (site) -> Promise<Void> in
      let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      let builder = Builder()
      return builder.build(fromSourceDirectory: site.documentsURL, toDestinationDirectory: destinationURL)
      // return builder.buildPromise(fromSourceDirectory: , toDestinationDirectory: T##URL)
    }.catch { error in
      self.onCompleted(error)
    }.then {
      self.onCompleted(nil)
    }
  }

  func onProgress(_: BuilderProgress) {}

  func onCompleted(_: Error?) {
    siteBuiling = false
  }

  var errorView: some View {
    let actualError: Error?
    if case let .failure(error) = self.themes {
      actualError = error
    } else {
      actualError = nil
    }
    return actualError.map { error in
      Text(error.localizedDescription)
    }
  }
}

#if DEBUG
  struct NewSiteView_Previews: PreviewProvider {
    static var previews: some View {
      NewSiteView()
    }
  }
#endif
