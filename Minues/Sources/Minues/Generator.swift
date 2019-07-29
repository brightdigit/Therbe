import Foundation

struct MissingTitleError : Error {}
struct NoDataError : Error {}

extension Array  : Error  where Element == Error{
  
}

public typealias ResultList<Element> = Result<[Element], [Error]>

class ResultListBuilder<Element> {
  var successes = [Element]()
  var failures = [Error]()
  
  func append (_ element : Element) {
    self.successes.append(element)
  }
  
  func append (_ error : Error) {
    self.failures.append(error)
  }
  
  var result : ResultList<Element> {
    if failures.count > 0 {
      return .failure(failures)
    } else {
      return .success(successes)
    }
  }
}
public class Generator   {
  let destinationURL : URL
  let count : Int
  let callback : (ResultList<Entry>) -> ()
  let group = DispatchGroup()
  var tasks : [URLSessionDownloadTask]!
  let resultListBuilder = ResultListBuilder<Entry>()
  
  let photoURLTemplate = "https://picsum.photos/id/%d/%d/%d"
  let markdownUrl = URL(string: "https://jaspervdj.be/lorem-markdownum/markdown.txt")!
  
  var state : URLSessionTask.State {
    var currentState : URLSessionTask.State?
    for task in self.tasks {
      switch task.state {
        
      case .running:
        return .running
      case .canceling:
        return .canceling
      default:
        if task.state == currentState || currentState == nil {
          currentState = task.state
        } else {
          return .running
        }
      }
    }
    return currentState ?? .suspended
  }
  
  init (destinationURL: URL, count: Int, callback: @escaping (ResultList<Entry>) -> ()) {
    self.destinationURL = destinationURL
    self.count = count
    self.callback = callback
    
    
    self.tasks = (1...count).map{ _ in
      URLSession.shared.downloadTask(with: markdownUrl, completionHandler: self.downloadCompletedAtURL(url:withResponse:andError:))
    }
  }
  
  public static func generate(_ count: Int, markdownFilesAt directoryURL: URL, _ completed: @escaping (ResultList<Entry>) -> ()) -> Generator {
    let generator = Generator(destinationURL: directoryURL, count: count, callback: completed)
    generator.begin()
    return generator
  }
  
  public func begin () {
    for task in self.tasks {
      group.enter()
      DispatchQueue.global().async {
        task.resume()
      }
    }
    group.notify(queue: .main) {
      
      self.callback(self.resultListBuilder.result)
    }
  }
  
  func downloadCompletedAtURL(url : URL?, withResponse response: URLResponse?, andError error: Error?) {
    let urlResult = Result(value: url, error: error, noDataError: NoDataError())
    let stringResult = urlResult.flatMap { (downloadURL) in
      Result{
        try String(contentsOf: downloadURL)
      }
    }
    let entryResult = stringResult.flatMap { (markdown) in
      return Result { () -> Entry in
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
        let maximumDistanceFromNow =  2600000.0 // one month from now
        let minimumDistanceFromNow = -47500000.0 // 1.5 years from now
        let timeInterval = TimeInterval.random(in: (minimumDistanceFromNow...maximumDistanceFromNow))
        let date = Date(timeIntervalSinceNow: timeInterval)
        let fileName = title.slugify() + ".md"
        let fileURL = self.destinationURL.appendingPathComponent(fileName)
        let frontMatter = FrontMatter(title: title, date: date, tags: ["a", "b", "c"], categories: ["a", "b", "c"], cover_image: URL(string: String(format: photoURLTemplate, Int.random(in: 1...1000), 1920, 960))!)
        return Entry(frontMatter: frontMatter, content: newMarkdown, url: fileURL)
      }
      
    }
    do {
      let entry = try Generator.write(entryResult)
      self.resultListBuilder.append(entry)
    }
    catch let error {
      self.resultListBuilder.append(error)
    }
    group.leave()
  }

  
  static fileprivate func write(_ entryResult: Result<Entry, Error>)  throws -> Entry {
    let entry : Entry
    entry = try entryResult.get()
    
    try entry.text.write(to: entry.url, atomically: false, encoding: .utf8)
    return entry
  }
}



