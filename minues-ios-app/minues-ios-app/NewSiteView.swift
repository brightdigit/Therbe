//
//  NewSiteView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/30/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Minues


struct Theme : Hashable  {
  let title : String
  let directoryURL : URL
  
  init?(configURL : URL) {

    let minues = Minues()
    guard let config = try? minues.yaml(fromURL: configURL) else {
      return nil
    }
    
    guard let title = config["title"] as? String else {
      return nil
    }
    self.title = title
    self.directoryURL = configURL.deletingLastPathComponent()
  }
}
struct NewSiteView: View {
  @State var pickedTheme : Theme?
  @State var themes : Result<[Theme], Error>?
  let loadingDirectoryUrl : URL = Bundle.main.url(forResource: "themes", withExtension: nil)!
  var body: some View {
    ZStack{
      busyView.onAppear {
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
    }

  }
  
  var busyView : some View {
    let loading = self.themes == nil ? Void() : nil
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
                    Picker(selection: $pickedTheme, label: Text("Theme")) {
                                            ForEach(0 ..< themes.count) {
                                                Text(themes[$0].title).tag($0)
            
                                            }
                                        }
                  }
                }
      }
    }
        
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