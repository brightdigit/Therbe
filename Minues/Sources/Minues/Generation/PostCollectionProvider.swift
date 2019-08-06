// PostCollectionProvider.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

public struct PostCollectionProvider: PostCollectionProviderProtocol {
  public init() {}
  public func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol {
    let collection = PostCollectionTask()
    (1 ... count).forEach { _ in
      collection.append(generator.next())
    }

    return collection
  }
}
