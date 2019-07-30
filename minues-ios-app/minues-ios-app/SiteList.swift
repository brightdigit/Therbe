//
//  SiteList.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import SwiftUI


struct URLImage : View {
  let url : URL
  let placeholder : Image
  @State var uiImage : UIImage?
  
  var body: some View {
    ZStack{
      loadingImage.onAppear{
        self.beginLoading()
      }
      actualImage
    }
  }
  
  var loadingImage : some View {
    return uiImage == nil ? placeholder : nil
  }
  
  var actualImage : some View {
    return uiImage.map {
      Image(uiImage: $0)
    }
  }
  
  func beginLoading () {
    URLSession.shared.dataTask(with: self.url) { (data, _, _) in
      self.uiImage = data.flatMap(UIImage.init(data:))
    }.resume()
  }
}

struct Site {
  let title : String
  let logoUrl : URL
  let id : UUID
  let domainName : String
  
  var documentsURL : URL {
    return Directories.shared.sitesDirectoryUrl.appendingPathComponent(id.uuidString)
  }
  #if DEBUG
  
  
  init (title: String, photoId: Int? = nil, id: UUID? = nil, domainName : String? = nil) {
    self.title = title
    self.id = id ?? UUID()
    let photoId = photoId ?? Int.random(in: 1...1000)
    self.logoUrl = URL(string: .init(format: "https://picsum.photos/id/%d/%d/%d", photoId, 1024, 1024))!
    self.domainName = title.filter{
      !$0.isWhitespace && !$0.isNewline
    }.lowercased() + ".com"
  }
  #endif
}


struct SiteList: View {
  @State var sites : [Site]
  @State var isPresented = false
  var body: some View {
    NavigationView{
      List(self.sites, id: \.id) { (site) in

        NavigationLink(destination: SiteDetails(site: site)) {
        HStack{
          URLImage(url: site.logoUrl, placeholder: Image(systemName: "photo")).frame(minWidth: 32, maxWidth: 64, minHeight: 32, maxHeight: 64).clipped().aspectRatio(contentMode: .fit)
          VStack(alignment: .leading) {
            Text(site.title)
            Text(site.domainName).font(.subheadline)
          }
        }
        }
      }.navigationBarTitle("Sites")
        .navigationBarItems(trailing: Button(action: self.newSite, label: {
          Text("New")
      }))
    }.sheet(isPresented: $isPresented) {
      NavigationView{
        NewSiteView(themes: [Theme(title: "Article Fox")])
        .navigationBarItems(trailing: HStack{
          Button(action: self.hideSite) {
            Text("Cancel")
          }
        })
      }
    }
  }

  func hideSite () {
    self.isPresented = false
  }
  func newSite () {
    self.isPresented = true
  }
}

#if DEBUG
struct SiteList_Previews: PreviewProvider {
  static var previews: some View {
    SiteList(sites: [
      Site(title: "Epsum factorial"),
        Site(title: "Non deposit"),
        Site(title: "Pro"),
        Site(title: "Quo hic"),
        Site(title: "Olypian"),
        Site(title: "Quarrels et"),
        Site(title: "Congolium")
    ])
  }
}
#endif
