// Result.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Foundation
public extension Result {
  init(value: Success?, error: Failure?, noDataError: Failure) {
    if let error = error {
      self = .failure(error)
    } else if let value = value {
      self = .success(value)
    } else {
      self = .failure(noDataError)
    }
  }

  var error: Error? {
    if case let .failure(error) = self {
      return error
    } else {
      return nil
    }
  }
}
