//
//  File.swift
//  
//
//  Created by Leo Dion on 7/22/19.
//

import Foundation

struct FrontMatter {
  let layout: String = "post"
  let title : String
  let tags : [String]
  let categories: [String]
  let cover_image: URL
  
  var yaml : String {
      return """
layout: \(self.layout)
title:  "\(self.title)"
tags: \(self.tags)
categories: \(self.categories)
cover_image: \(self.cover_image)
"""
    }
}
