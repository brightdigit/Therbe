// Regex.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation
infix operator =~
func =~ (value: String, pattern: String) -> [[Range<String.Index>]] {
  let string = value as NSString
  let options = NSRegularExpression.Options(rawValue: 0)

  guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
    return [[Range<String.Index>]]()
  }

  let all = NSRange(location: 0, length: string.length)
  let matchingOptions = NSRegularExpression.MatchingOptions(rawValue: 0)

  return regex.matches(in: value, options: matchingOptions, range: all).map { result in
    (0 ..< result.numberOfRanges).compactMap {
      Range(result.range(at: $0), in: value)
    }
  }
}
