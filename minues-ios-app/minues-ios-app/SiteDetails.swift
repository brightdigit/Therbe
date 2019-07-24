//
//  SiteDetails.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI

struct SiteDetails: View {
  let site : Site
  var body: some View {
      List{
        NavigationLink(destination: DirectoryList(siteName: site.title)) {
          HStack{
            Image(systemName: "folder")
            Text("Pages")
          }
        }
      }
    
  }
}

#if DEBUG
struct SiteDetails_Previews: PreviewProvider {
  static var previews: some View {
    SiteDetails(site: Site(title: "Lorem Ipsum"))
  }
}
#endif
