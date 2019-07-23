//
//  DirectoryList.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

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
    
  }
}

#if DEBUG
struct DirectoryList_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryList()
    }
}
#endif
