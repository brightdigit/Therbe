//
//  BuildView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/29/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI

struct BuildView: View {
  let site : Site
  
  var body: some View {
    Text("Building...")
  }
}

#if DEBUG
struct BuildView_Previews: PreviewProvider {
  static var previews: some View {
    BuildView(site: Site(title: "Lorem Ipsum"))
  }
}
#endif
