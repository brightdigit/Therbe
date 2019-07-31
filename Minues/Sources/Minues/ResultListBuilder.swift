// ResultListBuilder.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

class ResultListBuilder<Element> {
  var successes = [Element]()
  var failures = [Error]()

  func append(_ element: Element) {
    successes.append(element)
  }

  func append(_ error: Error) {
    failures.append(error)
  }

  var result: ResultList<Element> {
    if failures.count > 0 {
      return .failure(failures)
    } else {
      return .success(successes)
    }
  }
}
