// PostCollectionTaskProvider.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

// import Promises
public struct PostCollectionTaskProvider: PostCollectionTaskProviderProtocol {
  public init() {}
  public func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol {
    let collection = PostCollectionTask()
    (1 ... count).forEach { _ in
      collection.append(generator.next())
    }

    return collection
  }
}

import Foundation
public struct PostCollectionOperationProvider {
  public func operation(_ count: Int, postsUsing generator: PostGeneratorProtocol) -> Operation {
    let operation = Operation()
    (1 ... count).forEach { _ in
      operation.addDependency(generator.operation())
    }
    return operation
  }

  public func result(fromOperation operation: Operation) -> ResultList<ContentEntryProtocol> {
    operation.dependencies.compactMap {
      $0 as? PostGenerationOperation
    }.compactMap {
      $0.result
    }.flatten()
  }
}

// public struct PostCollectionPromiseProvider: PostCollectionPromiseProviderProtocol {
//  public func promise(_ count: Int, postsUsing generator: PostGeneratorProtocol) -> Promise<[ContentEntryProtocol]> {
//    let promises = (1 ... count).map {
//      _ in
//      generator.promise()
//    }
//
//    let result = all(promises)
//    return result
//  }
// }
