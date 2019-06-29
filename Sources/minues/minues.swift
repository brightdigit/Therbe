import Yams
import Down
import Foundation

infix operator =~
func =~ (value: String, pattern: String) -> RegexResult {
  let string = value as NSString
  let options = NSRegularExpression.Options(rawValue: 0)
  
  guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
    return RegexResult(results: [])
  }
  
  let all = NSRange(location: 0, length: string.length)
  let matchingOptions = NSRegularExpression.MatchingOptions(rawValue: 0)
  var matches: [String] = []
  
  regex.enumerateMatches(in: value, options: matchingOptions, range: all) {
    (result, flags, pointer) in
    let string = string.substring(with: result!.range)
    matches.append(string)
  }
  
  return RegexResult(results: matches)
}

struct RegexResult {
  let isMatching: Bool
  let matches: [String]
  
  init(results: [String]) {
    matches = results
    isMatching = matches.count > 0
  }
}


struct minues {
  func run () {
    let encodedYAML = """
    ---
    p: test
    ---
    ## [Down](https://github.com/iwasrobbed/Down)
    """
    
    
    
  }
  
  fileprivate func transformFrontMatter(_ markdown: String) -> String {
    let result = markdown =~ "^-{3}\n[\\s\\S]*?\n-{3}\n"
    if result.isMatching {
      let frontMatter = result.matches[0]
      let codeBlockString = frontMatter.replacingOccurrences(of: "---", with: "~~~")
      let hiddenMarkup = "<hr id='markoff-frontmatter-rule'>\n\n"
      return markdown.replacingOccurrences(of: frontMatter, with: hiddenMarkup + codeBlockString)
    } else {
      return markdown
    }
  }
}
