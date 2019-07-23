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
  
  let style: UIActivityIndicatorView.Style
}

struct DirectoryList: View {
  let siteName : String
  let dateFormatter = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()
   
  @State var generator : Generator?
  var isGenerating: Any?  {
    generator.flatMap{ self.result == nil ? $0 : nil }
  }
  @State var lastError : Error? {
    didSet {
      self.showError = self.lastError != nil
    }
  }
  @State var result : ResultList<MarkdownEntry>? {
    didSet {
      if case let .failure(error) = result {
        self.lastError = error
      }
    }
  }
  @State var showError : Bool = false {
    didSet {
      guard !showError else {
        return
      }
      guard self.lastError != nil else {
        return
      }
      self.lastError = nil
    }
  }
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
        list
        emptyText
        activityView
        
      }.alert(isPresented: $showError, content: {
        Alert(title: Text("Error"))
      })
        .navigationBarTitle(Text("\(self.siteName) Posts"))
        
        .navigationBarItems(trailing: Button(action: self.generate){ Text("Generate")}.disabled(isGenerating != nil))
      
      
    }
  }
  
  var list: some View {
    let items = self.result.flatMap { try? $0.get() }    
    
    return items.map { (entries) in
      return List(entries.sorted(by: { (lhs, rhs) -> Bool in
        return lhs.frontMatter.date > rhs.frontMatter.date
      }), id: \.url.lastPathComponent)  { entry in
        VStack(alignment: .leading) {
          Text(entry.frontMatter.title)
          Text(self.dateFormatter.string(from: entry.frontMatter.date)).font(.subheadline)
        }
        
      }
    }
  }
  
  var emptyText : some View {
    let items = self.result.flatMap { try? $0.get() }.flatMap{ $0.count == 0 ? $0 : nil }
   
    return items.map { _ in
      Text("No Items")
    }
  }
  
  var activityView: some View {
    
    return isGenerating.map { (_)  in
      ActivitiyIndicatorView(style: .large)
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
      self.result = result
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
