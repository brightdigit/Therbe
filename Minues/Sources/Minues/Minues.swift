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
}

protocol IncludeProtocol {
  var relativePath : String { get }
  var name : String { get }
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
    return url.lastPathComponent
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
    return url.lastPathComponent
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
  
}
protocol SiteDetailsProtocol {
  var content : [ContentProtocol] { get }
  var includes : [IncludeProtocol] { get }
  var layouts : [LayoutProtocol] { get }
  var configuration : SiteConfigurationProtocol { get }
  var baseUrl : URL { get }
}
struct SiteDetails : SiteDetailsProtocol {
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
    
    let includes : [String : String]
    let layouts  : [String : String]
    let content : [String : String]
    includes = [String : [IncludeProtocol]](grouping: site.includes, by: {
      $0.name
    }).compactMapValues{
      $0.compactMap{ try? environment.renderTemplate(name: $0.relativePath, context: site.configuration.context) }.first
    }
    
    
    
    do {
      layouts = [ String: [LayoutProtocol]](grouping: site.layouts, by: {
        $0.name
      }).compactMapValues{
        $0.compactMap{ try? environment.renderTemplate(name: $0.relativePath, context: site.configuration.context) }.first
      }
      
    }
      
    catch let error {
      return completed(error)
    }
    
    do {
      content = [ String: [ContentProtocol]](grouping: site.content, by: {
              $0.relativePath
            }).compactMapValues{
              $0.compactMap{ try? environment.renderTemplate(name: $0.relativePath, context: site.configuration.context) }.first
            }
    } catch let error {
      return completed(error)
    }
    
    for (pathComponent, text) in content {
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
