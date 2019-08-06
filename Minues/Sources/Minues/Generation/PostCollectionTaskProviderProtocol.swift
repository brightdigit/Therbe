// PostCollectionTaskProviderProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

public protocol PostCollectionTaskProviderProtocol {
  func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol
}

//
// import Promises
//
// public protocol PostCollectionPromiseProviderProtocol {
//  func promise(_ count: Int, postsUsing generator: PostGeneratorProtocol) -> Promise<[ContentEntryProtocol]>
// }
