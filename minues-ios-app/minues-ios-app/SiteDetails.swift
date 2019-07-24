//
//  SiteDetails.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI
import Minues

enum EntryType {
  case folder, page
}

extension EntryType {
  var systemName : String {
    switch self {
    case .folder :
      return "folder"
    case .page:
      return "doc.richtext"
    }
  }
}

protocol Entry {
  var type : EntryType { get }
  var name : String { get }
  var id : UUID { get }
}

class SitePreparation {
  
}

struct SiteDetails: View {
  let site : Site
  @State var result : ResultList<Entry>?
  var isActive : Bool {
    let items = result.flatMap{ try? $0.get()}
    return items == nil
  }
  var body: some View {
    ZStack{
      listView
      activityView
    }
    .navigationBarTitle(Text(site.title))
    .onAppear(perform: self.beginLoading)
//      List{
//        NavigationLink(destination: DirectoryList(siteName: site.title)) {
//          HStack{
//            Image(systemName: "folder")
//            Text("Pages")
//          }
//        }
//      }
    
  }
  
  func beginLoading () {
    
  }

  var activityView: some View {
    let view : ActivitiyIndicatorView?
      
      if isActive {
        view = ActivitiyIndicatorView(style: .large)
      } else {
        view = nil
      }
    return view
  }
  
  var listView : some View {
    return self.result.flatMap {
      try? $0.get()
    }.map { (entries) in
      List(entries, id: \.id) { (entry) in
        Text(entry.name)
      }
    }
//      List($0, id: \.id) {
//                NavigationLink(destination: DirectoryList(siteName: site.title)) {
//                  HStack{
//                    Image(systemName: $0.type.systemName)
//                    Text($0.name)
//                  }
//                }
//      }
    
  }
}

#if DEBUG
struct SiteDetails_Previews: PreviewProvider {
  static var previews: some View {
    SiteDetails(site: Site(title: "Lorem Ipsum"))
  }
}
#endif
