//
//  DirectoryList.swift
//  minues-ios-app
//
//  Created by Leo Dion on 7/23/19.
//  Copyright © 2019 BrightDigit. All rights reserved.
//

import Minues
import SwiftUI

struct NoDocumentDirectoryError : Error {}

struct ActivitiyIndicatorView : UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<ActivitiyIndicatorView>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: self.style)
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivitiyIndicatorView>) {
    uiView.startAnimating()
  }
  
  
  typealias UIViewType = UIActivityIndicatorView
  
  //@Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  //
  //  func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
  //    return UIActivityIndicatorView(style: style)
  //  }
  //
  //  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
  //    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  //  }
}

struct DirectoryList: View {
  let siteName : String
  @State var generator : Generator?
  @State var lastError : Error?
  @State var result : ResultList<URL>?
  @State var showError : Bool = true
  func getDirectoryURL() throws -> URL {
    let documentDirectoryUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    guard let documentDirURL = documentDirectoryUrls.first else {
      throw NoDocumentDirectoryError()
    }
    let markdownDirectoryURL = documentDirURL.appendingPathComponent("sites", isDirectory: true).appendingPathComponent(self.siteName, isDirectory: true).appendingPathComponent("posts", isDirectory: true)
    try  FileManager.default.createDirectory(at: markdownDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    return markdownDirectoryURL
  }
  
  var body: some View {
    NavigationView{
      ZStack{
        List{
          Text("First")
          Text("Second")
          Text("Third")
        }
        Text("No Items")
        ActivitiyIndicatorView(style: .large)
        
      }.alert(isPresented: $showError, content: {
        Alert(title: Text("Error"))
      })
        .navigationBarTitle(Text("\(self.siteName) Posts"))
        .navigationBarItems(trailing: Button(action: self.generate){ Text("Generate")})
    }
  }
  
  func generate () {
    let markdownDirectoryURL: URL
    do {
      markdownDirectoryURL = try self.getDirectoryURL()
    } catch let error {
      self.lastError = error
      return
    }
    let generator = Generator.generate(20, markdownFilesAt: markdownDirectoryURL) { (result) in
      print(result)
    }
    self.generator = generator
  }
}

#if DEBUG
struct DirectoryList_Previews: PreviewProvider {
  static var previews: some View {
    DirectoryList(siteName: "sample")
  }
}
#endif
