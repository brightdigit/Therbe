// PostGenerationTaskProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 8/1/19.

import Combine

public protocol PostGenerationTaskProtocol {
  mutating func completion(_ completion: @escaping (Result<ContentEntryProtocol, Error>) -> Void)
  func resume()
}
