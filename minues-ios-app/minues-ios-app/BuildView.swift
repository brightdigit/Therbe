//
//  BuildView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/29/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Minues

struct BuildView: View {
  let site : Site
  let builder = Builder()
  let destinationURL : URL
  
  var body: some View {
    Text("Building...").onAppear {
      self.builder.build(fromSourceDirectory: self.site.documentsURL, toDestinationDirectory: self.destinationURL, self.onProgress(_:), completed: self.onCompleted(_:))
    }
  }
  
  func onProgress (_ progress: BuilderProgress) {
    
  }
  
  func onCompleted (_ error: Error?) {
    debugPrint(error)
  }
}

#if DEBUG
struct BuildView_Previews: PreviewProvider {
  static var previews: some View {
    
    BuildView(site: Site(title: "Lorem Ipsum"), destinationURL: URL.temporaryDirectory())
  }
}
#endif
