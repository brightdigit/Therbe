//
//  DirectoryList.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import Minues
import SwiftUI

struct DirectoryList: View {
    var body: some View {
      NavigationView{
        Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
        .navigationBarTitle(Text("Text"))
          .navigationBarItems(trailing: Button(action: self.generate){ Text("Text")})
      }
    }
  
  func generate () {
    let documentDirectoryUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    guard let documentDirURL = documentDirectoryUrls.first else {
      return
    }
    let markdownDirectoryURL = documentDirURL.appendingPathComponent("sites", isDirectory: true).appendingPathComponent("sample", isDirectory: true).appendingPathComponent("posts", isDirectory: true)
    
    print(markdownDirectoryURL)
    try! FileManager.default.createDirectory(at: markdownDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    let generator = Generator.generate(20, markdownFilesAt: markdownDirectoryURL) { (result) in
      print(result)
      }
  }
}

#if DEBUG
struct DirectoryList_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryList()
    }
}
#endif
