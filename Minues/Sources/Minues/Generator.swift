import Foundation

struct MissingTitleError : Error {}
struct NoDataError : Error {}

extension Array  : Error  where Element == Error{
  
}

typealias ResultList<Element> = Result<[Element], [Error]>

let photoURLTemplate = "https://picsum.photos/id/%d/%d/%d"
let markdownUrl = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!


fileprivate func write(_ entryResult: Result<MarkdownEntry, Error>, toDirectory directoryURL : URL)  throws -> URL {
  let entry : MarkdownEntry
    entry = try entryResult.get()
  let fileName = entry.frontMatter.title.slugify() + ".md"
  let destinationURL = directoryURL.appendingPathComponent(fileName)
  
    try entry.text.write(to: destinationURL, atomically: false, encoding: .utf8)
    return destinationURL
  
}

func generateRandomMarkdown(ofCount count: Int, atDirectory directoryURL : URL, _ completed: @escaping (ResultList<URL>) -> ()) {

  let group = DispatchGroup()
  var fileNames  = [URL]()
  var errors = [Error]()
  for _ in (1...count) {
    group.enter()
    DispatchQueue.main.async {
      URLSession.shared.downloadTask(with: markdownUrl) { (url, _, error) in
        let urlResult = Result(value: url, error: error, noDataError: NoDataError())
        let stringResult = urlResult.flatMap { (downloadURL) in
          Result{
            try String(contentsOf: downloadURL)
          }
        }
        let entryResult = stringResult.flatMap { (markdown) in
          return Result { () -> MarkdownEntry in
            var foundTitle: String?
            var newMarkdown = markdown
            let results = markdown =~ "(#+)\\s(.+)"
            for result in results.reversed() {
              
              if markdown[result[1]].count == 1 {
                foundTitle = String( markdown[result[2]])
                newMarkdown.removeSubrange(result[0])
              } else {
                let imageAlt = markdown[result[2]]
                let imageUrl = String(format: photoURLTemplate, Int.random(in: 1...1000), 1920, 960)
                newMarkdown.insert(contentsOf: "![\(imageAlt)](\(imageUrl))\n\n", at: result[0].lowerBound)
              }
            }
            
            guard let title = foundTitle else {
              throw MissingTitleError()
            }
            let frontMatter = FrontMatter(title: title, tags: ["a", "b", "c"], categories: ["a", "b", "c"], cover_image: URL(string: String(format: photoURLTemplate, Int.random(in: 1...1000), 1920, 960))!)
            return MarkdownEntry(frontMatter: frontMatter, markdown: newMarkdown)
          }
          
        }
        do {
          let url = try write(entryResult, toDirectory: directoryURL)
          fileNames.append(url)
        }
        catch let error {
          errors.append(error)
        }
        group.leave()
      }.resume()
    }
  }
  group.notify(queue: .main) {
    let result : ResultList<URL>
    if errors.count > 0 {
      result = .failure(errors)
    } else {
      result = .success(fileNames)
    }
    completed(result)
  }
}
