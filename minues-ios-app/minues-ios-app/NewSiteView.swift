//
//  NewSiteView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/30/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Minues



struct NewSiteView: View {
  var readyForBuild : Bool {
    return !(siteTitle.isEmpty)
  }
  @State var siteBuiling = false
  @State var siteTitle : String = ""
  @State var pickedThemeIndex = 0
  @State var themes : Result<[Theme], Error>?
  let loadingDirectoryUrl : URL = Bundle.main.url(forResource: "themes", withExtension: nil)!
  var body: some View {
    ZStack{
      inputView
      errorView
      busyView.onAppear(perform: self.beginLoad)
    }
    
  }
  
  func beginLoad () {
    var themeConfigs = [URL]()
    guard let enumerator = FileManager.default.enumerator(at: self.loadingDirectoryUrl, includingPropertiesForKeys: nil) else {
      return
    }
    while let url = enumerator.nextObject() as? URL {
      if url.lastPathComponent == "_config.yml" {
        themeConfigs.append(url)
      }
    }
    self.themes = .success(themeConfigs.compactMap(Theme.init(configURL:)))
  }
  
  var busyView : some View {
    let loading : Void? = (self.themes == nil || self.siteBuiling) ? Void() : nil
    return loading.map {
      ActivitiyIndicatorView(style: .large)
    }
    
  }
  
  var inputView : some View {
    self.themes.flatMap {
      (try? $0.get()).map {
        (themes) in
        Form{
          Section{
            TextField("Name", text: $siteTitle)
          }
          Section{
            Picker(selection: $pickedThemeIndex, label: Text("Theme")) {
              ForEach(0 ..< themes.count) {
                Text(themes[$0].title).tag($0)
                
              }
            }
          }
          Section{
            Button(action: self.beginBuild) {
              Text("Build")
            }.disabled(!self.readyForBuild)
          }
        }
      }
    }
    
  }
  
  func beginBuild () {
    self.siteBuiling = true
    let minues = Minues()
    
    let chosenTheme =  self.themes.flatMap{ try? $0.get() }.flatMap{ $0[self.pickedThemeIndex] }
    
    guard let theme = chosenTheme else {
      return
    }
    let site = Site(title: self.siteTitle)

    // copy theme template
    // generate posts
    //
    minues.setupSite(site, withTheme: theme) { (error) in
      if let error = error {
        return
      }
      let builder = Builder()
      let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      builder.build(fromSourceDirectory: site.documentsURL, toDestinationDirectory: destinationURL, self.onProgress, completed: self.onCompleted)
    }
  }
  
  func onProgress (_ progres : BuilderProgress) {
    
  }
  
  func onCompleted (_ error: Error?) {
    self.siteBuiling = false
  }
  
  var errorView : some View {
    let actualError : Error?
    if case let .failure(error) = self.themes {
      actualError = error
    } else {
      actualError = nil
    }
    return actualError.map { (error) in
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
