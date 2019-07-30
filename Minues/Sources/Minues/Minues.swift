import Yams
import Down
import Stencil
import Foundation
import PathKit

public extension URL {
  func pathComponentIndex(commonWith base: URL) -> Int? {
    // Ensure that both URLs represent files:
    guard self.isFileURL && base.isFileURL else {
      return nil
    }
    
    // Remove/replace "." and "..", make paths absolute:
    let destComponents = self.standardized.pathComponents
    let baseComponents = base.standardized.pathComponents
    
    // Find number of common path components:
    var i = 0
    while i < destComponents.count && i < baseComponents.count
      && destComponents[i] == baseComponents[i] {
        i += 1
    }
    
    return i
    
    // Build relative path:
    //    var relComponents = Array(repeating: "..", count: baseComponents.count - i)
    //    relComponents.append(contentsOf: destComponents[i...])
    //    return relComponents.joined(separator: "/")
  }
  
  static func temporaryDirectory () -> URL {
    return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
  }
}
public struct NotImplementedError : Error {
  
}


@available(*, deprecated)
struct RegexResult {
  let isMatching: Bool
  let matches: [String]
  
  init(results: [String]) {
    matches = results
    isMatching = matches.count > 0
  }
}

public struct BuilderProgress {
  
}

protocol SiteConfigurationProtocol {
  var context : [String : Any] { get }
}

struct SiteConfiguration : SiteConfigurationProtocol {
  let context: [String : Any]
}

protocol LayoutProtocol {
  var relativePath : String { get }
  var name : String { get }
  func contents() throws -> String
}

protocol IncludeProtocol {
  var relativePath : String { get }
  var name : String { get }
  func contents() throws -> String
}

struct Stylesheet : StylesheetProtocol {
  let baseUrl : URL
  let url : URL
  var relativePath: String {
    guard let index = url.pathComponentIndex(commonWith: self.baseUrl) else {
      return url.absoluteString
      
    }
    
    return url.pathComponents[index...].joined(separator: "/")
  }
  
  var name: String {
    return url.deletingPathExtension().lastPathComponent
  }
  func contents() throws -> String {
    return try String(contentsOf: self.url)
  }
}
struct Include : IncludeProtocol {
  let baseUrl : URL
  let url : URL
  var relativePath: String {
    guard let index = url.pathComponentIndex(commonWith: self.baseUrl) else {
      return url.absoluteString
      
    }
    
    return url.pathComponents[index...].joined(separator: "/")
  }
  
  var name: String {
    return url.deletingPathExtension().lastPathComponent
  }
  func contents() throws -> String {
    return try String(contentsOf: self.url)
  }
  
}

struct Layout : LayoutProtocol {
  let baseUrl : URL
  let url : URL
  var relativePath: String {
    guard let index = url.pathComponentIndex(commonWith: self.baseUrl) else {
      return url.absoluteString
      
    }
    
    return url.pathComponents[index...].joined(separator: "/")
  }
  
  var name: String {
    return url.deletingPathExtension().lastPathComponent
  }
  func contents() throws -> String {
    return try String(contentsOf: self.url)
  }
}
protocol SiteFileBuilderProtocol {
  mutating func add(_ type: SiteFileType, for url: URL)
  var site : SiteDetailsProtocol { get }
}
enum SiteFileType {
  case layout, content, stylesheet, configuration, include
}
struct SiteFileBuilder : SiteFileBuilderProtocol  {
  let baseUrl : URL
  var files = [SiteFileType : [URL]]()
  var site: SiteDetailsProtocol {
    SiteDetails(
    stylesheets: files[.stylesheet]?.map(self.stylesheet(_:)) ?? [StylesheetProtocol](),
      content: files[.content]?.map(self.content(_:)) ?? [ContentProtocol](),
      includes: files[.include]?.map(self.include(_:)) ?? [IncludeProtocol](),
      layouts: files[.layout]?.map(self.layout(_:)) ?? [LayoutProtocol](),
      configuration: self.configuration(files[.configuration]), baseUrl: self.baseUrl)
  }
  
  mutating func add(_ type: SiteFileType, for url: URL) {
    var list : [URL] = files[type] ?? [URL]()
    list.append(url)
    files[type] = list
  }
  
  func content (_ url: URL) -> ContentProtocol {
    return Content(baseUrl: self.baseUrl, url: url)
  }
  
  func include (_ url: URL) -> IncludeProtocol {
    return Include(baseUrl: self.baseUrl, url: url)
  }
  
  func layout (_ url: URL) -> LayoutProtocol {
    return Layout(baseUrl: self.baseUrl, url: url)
  }

  func stylesheet (_ url: URL) -> StylesheetProtocol {
    return Stylesheet(baseUrl: self.baseUrl, url: url)
  }
  
  func configuration (_ urls: [URL]?) -> SiteConfigurationProtocol {
    guard let urls = urls else {
      return SiteConfiguration(context: [String : Any]())
    }
    let context = urls.compactMap{
      try? String(contentsOf: $0)
    }.compactMap{
      try? Yams.load(yaml: $0) as? [String : Any]
    }.reduce([String : Any](), Dictionary.merging)
    return SiteConfiguration(context: context)
  }
}

extension Dictionary {
  static func merging (_ lhs: Self, _ rhs: Self) -> Self {
    return lhs.merging(rhs, uniquingKeysWith: {lhs,_ in lhs})
  }
}
protocol ContentProtocol {
  
  var relativePath : String { get }
  
  var name: String { get }
  var isPost : Bool { get }
  func contents() throws -> String
  var isMarkdown : Bool  { get }
}
struct Content : ContentProtocol {
  let baseUrl : URL
  let url : URL
  var relativePath: String {
    guard let index = url.pathComponentIndex(commonWith: self.baseUrl) else {
      return url.absoluteString
      
    }
    
    return url.pathComponents[index...].joined(separator: "/")
  }
  
  func contents() throws -> String {
    return try String(contentsOf: self.url)
  }
  
  var isPost: Bool {
    url.deletingLastPathComponent().lastPathComponent == "_posts"
  }
  
  var isMarkdown: Bool {
    url.pathExtension == "md"
  }
  
  var name: String {
    return url.deletingPathExtension().lastPathComponent
  }
}
protocol StylesheetProtocol {
  func contents() throws -> String
  var relativePath: String { get }
}
protocol SiteDetailsProtocol {
  var stylesheets : [StylesheetProtocol] { get }
  var content : [ContentProtocol] { get }
  var includes : [IncludeProtocol] { get }
  var layouts : [LayoutProtocol] { get }
  var configuration : SiteConfigurationProtocol { get }
  var baseUrl : URL { get }
}
struct SiteDetails : SiteDetailsProtocol {
  
  let stylesheets: [StylesheetProtocol]
  let content: [ContentProtocol]
  
  let includes: [IncludeProtocol]
  
  let layouts: [LayoutProtocol]
  
  let configuration: SiteConfigurationProtocol
  
  let baseUrl: URL
  
  
}
struct SiteDetailsEnumerator {
  func details(fromSourceUrl sourceDirectoryUrl: URL) throws -> SiteDetailsProtocol {
    var builder = SiteFileBuilder(baseUrl: sourceDirectoryUrl)
    
    guard let enumerator = FileManager.default.enumerator(at: sourceDirectoryUrl, includingPropertiesForKeys: [.isDirectoryKey]) else {
      throw NotImplementedError()
    }
    while let object = enumerator.nextObject() {
      guard let url = object as? URL else {
        continue
      }
      guard let index = url.pathComponentIndex(commonWith: sourceDirectoryUrl) else {
        //print(url.pathComponents[index])
        continue
      }
      let paths = url.pathComponents[index...]
      
      if paths.first == "_layouts" {
        if url.pathExtension == "html"  {
          builder.add(.layout, for: url)
        }
      } else if paths.first == "_posts" {
        if url.pathExtension == "html" || url.pathExtension == "md" {
          builder.add(.content, for: url)
        }
      } else if paths.first == "css" {
        builder.add(.stylesheet, for: url)
      } else if paths.first == "_includes" {
        if url.pathExtension == "html" {
          builder.add(.include, for: url)
        }
      } else if (try? url.resourceValues(forKeys: [.isDirectoryKey]).allValues[.isDirectoryKey]) as? NSNumber == NSNumber(booleanLiteral: false) {
        if url.pathExtension == "yml" {
          builder.add(.configuration, for: url)
        } else if url.pathExtension == "html" || url.pathExtension == "md" || url.pathExtension == "xml" {
          builder.add(.content, for: url)
        }
      }
      
    }
    return builder.site
  }
}

enum ContentType {
  case page, post
}

public struct Builder {
  
  public init () {
    
  }
  public func build (fromSourceDirectory sourceURL: URL, toDestinationDirectory destinationURL: URL, _ progress: (BuilderProgress) -> Void, completed: (Error?) -> Void) {
    
    let enumerator = SiteDetailsEnumerator()
    let site : SiteDetailsProtocol
    do {
      site = try enumerator.details(fromSourceUrl: sourceURL)
    } catch let error {
      return completed(error)
      
    }
    
    let environment = Environment(loader: FileSystemLoader(paths: [Path(site.baseUrl.path)]), extensions: nil)
    
    
    let includes : [String : Any]
    let layouts  : [String : Any]
    let content : [(String, String)]
    
    let stylesheets : [(String, String)]
    includes = [String : [IncludeProtocol]](grouping: site.includes, by: {
      $0.name
    }).compactMapValues{
      $0.compactMap{ try? $0.contents() }.first
    }
    
    
    
    do {
      layouts = [ String: [LayoutProtocol]](grouping: site.layouts, by: {
        $0.name
      }).compactMapValues{
        $0.compactMap{ try? $0.contents() }.first
      }
      
    }
      
    catch let error {
      return completed(error)
    }
    
    
    let minues = Minues()
    let allContent = site.content.compactMap{
      (file) -> [String : Any]? in
      guard let text = try? file.contents() else {
        return nil
      }
      guard let components = try? minues.componentsFromMarkdown(text) else {
        return nil
      }
      let (pageAny, str) = components
      
      guard var page = pageAny as? [String : Any] else {
        return nil
      }
      
      if let dateAny = page["date"] {
        guard let date = dateAny as? Date else {
          return nil
        }
        
        guard date < Date() else {
          return nil
        }
      }
      
      page["url"] = file.name == "index" ? "index.html" : [file.name, "index.html"].joined(separator: "/")
      page["isPost"] = file.isPost
      
      return page
    }.sorted(by: { (lhs, rhs) -> Bool in
      let lhsDate = lhs["date"].flatMap{ $0 as? Date } ?? Date.distantPast
      let rhsDate = rhs["date"].flatMap{ $0 as? Date } ?? Date.distantPast
      return lhsDate > rhsDate
    })
    let contentDictionary = Dictionary<ContentType, [[String : Any]]>(grouping: allContent, by: { ($0["isPost"] as? Bool ?? false)  ? .post : .page})
    
    
    content = site.content.compactMap { (file) -> (String, String)? in
      print(file.name)
      guard let text = try? file.contents() else {
        return nil
      }
      guard let components = try? minues.componentsFromMarkdown(text) else {
        return nil
      }
      let (pageAny, str) = components
      let htmlRendered : String?
      if file.isMarkdown {
        
        let down = Down(markdownString: str)
        htmlRendered = try? down.toHTML()
      } else {
        htmlRendered = str
      }
      
      guard let page = pageAny as? [String : Any] else {
        return nil
      }
      guard let html = htmlRendered else {
        return nil
      }
      guard let layoutName = page["layout"] as? String else {
        return nil
      }
      let path = file.name == "index" ? "index.html" : [file.name, "index.html"].joined(separator: "/")
      var context : [String : Any] = ["site" : site.configuration.context, "page" : page, "posts" : contentDictionary[.post], "pages" : contentDictionary[.page]]
      guard let contentHtml = try? environment.renderTemplate(string: html, context: context) else {
        return nil
      }
      context["content"] = contentHtml
      
      guard let layout = layouts[layoutName] as? String else {
        return nil
      }
      do {
        return (path, try environment.renderTemplate(string: layout, context: context))
      } catch let error {
        debugPrint(error)
        return nil
      }
    }
    
    stylesheets = site.stylesheets.compactMap({ (stylesheet) in
      return (try? stylesheet.contents()).map{ (stylesheet.relativePath, $0)}
    })
    
    for (pathComponent, text) in (content + stylesheets) {
      let fileUrl = destinationURL.appendingPathComponent(pathComponent)
      let directoryUrl = fileUrl.deletingLastPathComponent()
      
      do {
        try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        try text.write(to: fileUrl, atomically: false, encoding: .utf8)
      } catch let error {
        return completed(error)
      }
    }
    
    print(destinationURL)
    completed(nil)
  }
  
  
}

public struct Minues {
  public init () {
    
  }
  public func yaml(fromURL url: URL) throws -> [String : Any] {
    let text = try String(contentsOf: url)
    
    guard let yaml = try Yams.load(yaml: text) as? [String : Any] else {
      throw NoDataError()
    }
    return yaml
  }
  public func run (fromString encodedYAML: String) throws -> String {
    //    let components = try componentsFromMarkdown(encodedYAML)
    //    if let dictionary = components.frontMatter as? [String : Any] {
    //      let template = Template(templateString: try components.markdown.toHTML())
    //      return try template.render(dictionary)
    //    } else {
    //      return try components.markdown.toHTML()
    //    }
    throw NotImplementedError()
  }
  
  public func run (fromEntry entry: Entry) throws -> String {
    //let down = Down(markdownString: entry.markdown)
    //let template = Template(templateString: try down.toHTML())
    //return try template.render(entry.frontMatter.dictionary)
    throw NotImplementedError()
  }
  
  
  fileprivate func componentsFromMarkdown(_ text: String) throws -> (frontMatter : Any?, content: String) {
    let result = text =~ "^-{3}\n([\\s\\S]*?)\n-{3}\n"
    let ranges = result.first
    let totalRange = ranges?.first
    let fmRange = ranges?.last
    if let totalRange = totalRange, let fmRange = fmRange, ranges?.count == 2 {
      let frontMatter = text[fmRange]
      let yaml = try Yams.load(yaml: String(frontMatter))
      let content = text[totalRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
      //let down = Down(markdownString: String(content))
      
      return (frontMatter: yaml, content: content)
      
    } else {
      return (frontMatter: nil, content: text)
      
    }
  }
}
