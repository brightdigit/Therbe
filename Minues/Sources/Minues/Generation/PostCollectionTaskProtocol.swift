// PostCollectionTaskProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Combine

public protocol PostCollectionTaskProtocol {
  mutating func completion(_ completion: @escaping (ResultList<ContentEntryProtocol>) -> Void)
  mutating func progress(_ progress: @escaping (Result<ContentEntryCollectionProgress, Error>) -> Void)
  func resume()
}
