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
  public let layout: String = "post"
  public let title : String
  public let date: Date
  public let tags : [String]
  public let categories: [String]
  public let cover_image: URL
  
  public var yaml : String {
      return """
layout: \(self.layout)
title:  "\(self.title)"
date: \(dateFormatter.string(from: self.date))
tags: \(self.tags)
categories: \(self.categories)
cover_image: \(self.cover_image)
"""
    }
  
  public var dictionary: [String : Any] {
    return [
      "title" : self.title,
      "layout" : self.layout,
      "date": self.date,
      "tags": self.tags,
      "categories": self.categories,
      "cover_image": self.cover_image
    ]
  }
}
