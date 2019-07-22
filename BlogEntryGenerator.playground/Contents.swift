import Foundation
import PlaygroundSupport

print("test")
struct NoDataError : Error {}

infix operator =~
func =~ (value: String, pattern: String) -> [[Range<String.Index>]] {
  let string = value as NSString
  let options = NSRegularExpression.Options(rawValue: 0)
  
  guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
    return [[Range<String.Index>]]()
  }
  
  let all = NSRange(location: 0, length: string.length)
  let matchingOptions = NSRegularExpression.MatchingOptions(rawValue: 0)
  
  return regex.matches(in: value, options: matchingOptions, range: all).map { (result) in
    (0..<result.numberOfRanges).compactMap {
      Range(result.range(at: $0), in: value)
    }
  }
}

extension Result {
  init(value: Success?, error: Failure?, noDataError: Failure) {
    if let error = error {
      self = .failure(error)
    } else if let value = value {
      self = .success(value)
    } else {
      self = .failure(noDataError)
    }
  }
}
struct FrontMatter {
  let layout: String = "post"
  let title : String
  let tags : [String]
  let categories: [String]
  let cover_image: URL
}

//let photoUrlComponent = URLComponents(string: "https://picsum.photos/id/")!
let markdownUrl = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!

let count = 20

let group = DispatchGroup()
print("test")
PlaygroundPage.current.needsIndefiniteExecution = true
for _ in (1...20) {
  group.enter()
  DispatchQueue.main.async {
    URLSession.shared.downloadTask(with: markdownUrl) { (url, _, error) in
      let urlResult = Result(value: url, error: error, noDataError: NoDataError())
      let stringResult = urlResult.flatMap { (downloadURL) in
        Result{
          try String(contentsOf: downloadURL)
        }
      }
      stringResult.map { (markdown) in
        let results = markdown =~ "(#+)\\s(.+)"
        for result in results.reversed() {
          
          print(markdown[result[0]])
        }
      }

      group.leave()
    }.resume()
  }
}

group.notify(queue: .main) {
  PlaygroundPage.current.finishExecution()
}
  /*
---
layout: post
title:  "Welcome to Jekyll!"
tags: []
categories: []
cover_image
---

# Welcome

**Hello world**, this is my first Jekyll blog post.

I hope you like it!
*/
