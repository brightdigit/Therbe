// Result.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

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

extension Array {
  func flatten<Success>() -> ResultList<Success> where Element == Result<Success, Error> {
    var successes = [Success]()
    var failures = [Error]()

    for item in self {
      switch item {
      case let .success(value):
        successes.append(value)
      case let .failure(error):
        failures.append(error)
      }
    }

    if failures.count > 0 {
      return .failure(failures)
    } else {
      return .success(successes)
    }
  }
}
