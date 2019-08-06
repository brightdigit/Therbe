// PostGeneratorProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Promises

public protocol PostGeneratorProtocol {
  func next() -> PostGenerationTaskProtocol
}

extension PostGeneratorProtocol {
  func promise() -> Promise<ContentEntryProtocol> {
    return Promise { succeed, failure in

      var task = self.next()
      task.completion {
        result in

        switch result {
        case let .success(value):
          succeed(value)
        case let .failure(error):
          failure(error)
        }
      }
      task.resume()
    }
  }
}
