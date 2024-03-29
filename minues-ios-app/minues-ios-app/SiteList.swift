// SiteList.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import SwiftUI

import Minues

struct URLImage: View {
  let url: URL
  let placeholder: Image
  @State var uiImage: UIImage?

  var body: some View {
    ZStack {
      loadingImage.onAppear {
        self.beginLoading()
      }
      actualImage
    }
  }

  var loadingImage: some View {
    return uiImage == nil ? placeholder : nil
  }

  var actualImage: some View {
    return uiImage.map {
      Image(uiImage: $0)
    }
  }

  func beginLoading() {
    URLSession.shared.dataTask(with: url) { data, _, _ in
      self.uiImage = data.flatMap(UIImage.init(data:))
    }.resume()
  }
}

struct SiteList: View {
  @State var sites: [Site]
  @State var isPresented = false
  var body: some View {
    NavigationView {
      List(self.sites, id: \.id) { site in

        NavigationLink(destination: SiteDetails(site: site)) {
          HStack {
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
      NavigationView {
        NewSiteView()
          .navigationBarItems(trailing: HStack {
            Button(action: self.hideSite) {
              Text("Cancel")
            }
          })
      }
    }
  }

  func hideSite() {
    isPresented = false
  }

  func newSite() {
    isPresented = true
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
        Site(title: "Congolium"),
      ])
    }
  }
#endif
