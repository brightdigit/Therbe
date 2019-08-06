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
