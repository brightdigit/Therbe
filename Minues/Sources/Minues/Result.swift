//
//  File.swift
//  
//
//  Created by Leo Dion on 7/22/19.
//

import Foundation
extension Result {
  init(value: Success?, error: Failure?, noDataError: Failure) {
    if let error = error {
      self = .failure(error)
    } else if let value = value {
      self = .success(value)
    } else {
      self = .failure(noDataError)
    }
  }
}
