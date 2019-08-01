// PostCollectionTask.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

public class PostCollectionTask: PostCollectionTaskProtocol {
  var completions = [(ResultList<ContentEntryProtocol>) -> Void]()
  var progresses = [(Result<ContentEntryCollectionProgress, Error>) -> Void]()

  var result: ResultList<ContentEntryProtocol>? {
    didSet {
      result.map(report(result:))
    }
  }

  func report(result: ResultList<ContentEntryProtocol>) {
    completions.forEach { $0(result) }
  }

  public func completion(_ callback: @escaping (ResultList<ContentEntryProtocol>) -> Void) {
    completions.append(callback)
    result.map(callback)
  }

  public func progress(_ callback: @escaping (Result<ContentEntryCollectionProgress, Error>) -> Void) {
    progresses.append(callback)
  }

  let builder = ResultListBuilder<ContentEntryProtocol>()
  private var tasks = [PostGenerationTaskProtocol]()

  func append(_ task: PostGenerationTaskProtocol) {
    assert(builder.count == 0, "Cannot add tasks after operation has started.")
    var newTask = task
    newTask.completion(taskCompleted)
    tasks.append(newTask)
  }

  func taskCompleted(_ result: Result<ContentEntryProtocol, Error>) {
    let percent = Float(builder.count) / Float(tasks.count)
    let progress = result.map { _ in ContentEntryCollectionProgress.progress(percent) }
    progresses.forEach { $0(progress) }
    builder.append(result)
    print(percent)
    if builder.count >= tasks.count {
      self.result = builder.result
    }
  }

  public func resume() {
    tasks.forEach { $0.resume() }
  }
}
