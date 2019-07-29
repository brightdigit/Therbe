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

protocol EntryProtocol {
  var type : EntryType { get }
  var name : String { get }
  var id : UUID { get }
}

struct BasicEntry : EntryProtocol {
  let type: EntryType
  
  let url: URL
  
  let id: UUID = UUID()
  
  var name : String {
    return url.lastPathComponent
  }
}

class SitePreparation {
  
}

struct SiteDetails: View {
  let site : Site
  @State var result : Result<[EntryProtocol], Error>?
  @State var isPresented = false
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
      .navigationBarItems(trailing:
        Button("Build") {
          self.isPresented = true
      })
      
      .onAppear(perform: self.beginLoading)
      .sheet(isPresented: $isPresented, content: {
        NavigationView{
          BuildView(site: self.site, destinationURL: URL.temporaryDirectory())
            .navigationBarItems(trailing:
              Button("Cancel") {
                self.isPresented = false
              }
          )
        }
      })
    
  }
  
  
  func beginLoading () {
    guard let themeDirectoryUrl = Bundle.main.url(forResource: "arctic-fox-theme", withExtension: nil) else {
      return
    }
    let siteDirectoryUrl = self.site.documentsURL
    var isDirectory : ObjCBool = false
    let isExists = FileManager.default.fileExists(atPath: siteDirectoryUrl.path, isDirectory: &isDirectory)
    if isExists && !isDirectory.boolValue {
      try? FileManager.default.removeItem(at: siteDirectoryUrl)
    }
    
    try? FileManager.default.createDirectory(at: Directories.shared.sitesDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
    try? FileManager.default.copyItem(at: themeDirectoryUrl, to: siteDirectoryUrl)
    print(siteDirectoryUrl)
    let postsUrl = siteDirectoryUrl.appendingPathComponent("_posts", isDirectory: true)
    _ = Generator.generate(20, markdownFilesAt: postsUrl) { (_) in
      let urls = try? FileManager.default.contentsOfDirectory(at: siteDirectoryUrl, includingPropertiesForKeys: [.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions.init()).filter{
        (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true || ["html", "md", "markdown"].contains($0.pathExtension)
      }
      let items = urls?.compactMap({ (url) -> EntryProtocol? in
        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        if isDirectory {
          let pages = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .init()).contains {
            ["html", "md", "markdown"].contains($0.pathExtension)
          }
          if pages == true {
            return BasicEntry(type: .folder, url: url)
          }
        } else {
          return BasicEntry(type: .page, url: url)
        }
        return nil
      })
      
      self.result = Result {
        guard let items = items else {
          throw NoDocumentDirectoryError()
        }
        return items
      }
    }
    
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
        HStack{
          Image(systemName: entry.type.systemName)
          Text(entry.name)
        }
        
      }
    }
    
  }
}

#if DEBUG
struct SiteDetails_Previews: PreviewProvider {
  static var previews: some View {
    let details = SiteDetails(site: Site(title: "Lorem Ipsum"))
    details.isPresented = true
    return details
  }
}
#endif
