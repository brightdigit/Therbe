//
//  File.swift
//  
//
//  Created by Leo Dion on 7/22/19.
//

import Foundation

protocol DateStringFormatter {
  func string(from: Date) -> String
}

extension DateFormatter : DateStringFormatter {
  
}

@available(iOS 10.0, *)
extension ISO8601DateFormatter : DateStringFormatter {
  
}

public struct FrontMatter {
  let dateFormatter : DateStringFormatter = {
    if #available(iOS 10.0, *) {
      return ISO8601DateFormatter()
    } else {
      let formatter = DateFormatter()
              formatter.calendar = Calendar(identifier: .iso8601)
              formatter.locale = Locale(identifier: "en_US_POSIX")
              formatter.timeZone = TimeZone(secondsFromGMT: 0)
              formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
              return formatter
    }
  }()
  let layout: String = "post"
  let title : String
  let date: Date
  let tags : [String]
  let categories: [String]
  let cover_image: URL
  
  var yaml : String {
      return """
layout: \(self.layout)
title:  "\(self.title)"
date: \(dateFormatter.string(from: self.date))
tags: \(self.tags)
categories: \(self.categories)
cover_image: \(self.cover_image)
"""
    }
}
