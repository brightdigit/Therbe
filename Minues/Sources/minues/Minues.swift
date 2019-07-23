import Yams
import Down
import Stencil
import Foundation



@available(*, deprecated)
struct RegexResult {
  let isMatching: Bool
  let matches: [String]
  
  init(results: [String]) {
    matches = results
    isMatching = matches.count > 0
  }
}


struct minues {
  func run () throws -> String {
    let encodedYAML = """
    ---
    first: 1st
    second: 2nd
    ---
    ## [Down](https://github.com/iwasrobbed/Down)
    * {{first}}
    * {{second}}
    """
    let components = try componentsFromMarkdown(encodedYAML)
    if let dictionary = components.frontMatter as? [String : Any] {
      let template = Template(templateString: try components.markdown.toHTML())
      return try template.render(dictionary)
    } else {
      return try components.markdown.toHTML()
    }
    
  }
  
//
//  fileprivate func transformFrontMatter(_ markdown: String) -> String {
//    let result = markdown =~ "^-{3}\n[\\s\\S]*?\n-{3}\n"
//    if let match = result.first {
//      let frontMatter = markdown[match]
//      let codeBlockString = frontMatter.replacingOccurrences(of: "---", with: "~~~")
//      let hiddenMarkup = "<hr id='markoff-frontmatter-rule'>\n\n"
//      return markdown.replacingOccurrences(of: frontMatter, with: hiddenMarkup + codeBlockString)
//    } else {
//      return markdown
//    }
//  }
//

  
  fileprivate func componentsFromMarkdown(_ markdown: String) throws -> (frontMatter : Any?, markdown: Down) {
    let result = markdown =~ "^-{3}\n([\\s\\S]*?)\n-{3}\n"
    let ranges = result.first
    let totalRange = ranges?.first
    let fmRange = ranges?.last
    if let totalRange = totalRange, let fmRange = fmRange, ranges?.count == 2 {
      let frontMatter = markdown[fmRange]
      let yaml = try Yams.load(yaml: String(frontMatter))
      let content = markdown[totalRange.upperBound...]
      let down = Down(markdownString: String(content))
      
      return (frontMatter: yaml, markdown: down)
      
    } else {
      return (frontMatter: nil, markdown: Down(markdownString: markdown))
      
    }
  }
}
