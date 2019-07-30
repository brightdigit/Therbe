//
//  NewSiteView.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/30/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI



struct Theme : Hashable  {
  let title : String
}
struct NewSiteView: View {
  @State var pickedTheme : Theme?
  let themes : [Theme]
  var body: some View {
    Form{
      Section{
        Picker(selection: $pickedTheme, label: Text("Theme")) {
                                ForEach(0 ..< themes.count) {
                                    Text(self.themes[$0].title).tag($0)

                                }
                            }
      }
    }
  }
}

#if DEBUG
struct NewSiteView_Previews: PreviewProvider {
  static var previews: some View {
    NewSiteView(themes: [Theme(title: "Artic Fox")])
  }
}
#endif
