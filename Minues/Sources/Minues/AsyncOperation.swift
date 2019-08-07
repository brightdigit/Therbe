// AsyncOperation.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

public class AsyncOperation: Operation {
  public override var isAsynchronous: Bool {
    return true
  }

  var asyncFinished: Bool = false

  public override var isFinished: Bool {
    set {
      willChangeValue(forKey: "isFinished")
      asyncFinished = newValue
      didChangeValue(forKey: "isFinished")
    }

    get {
      return asyncFinished
    }
  }

  var asyncExecuting: Bool = false

  public override var isExecuting: Bool {
    set {
      willChangeValue(forKey: "isExecuting")
      asyncExecuting = newValue
      didChangeValue(forKey: "isExecuting")
    }

    get {
      return asyncExecuting
    }
  }

  func execute() {}

  public override func start() {
    isExecuting = true
    execute()
    isExecuting = false
    isFinished = true
  }
}
