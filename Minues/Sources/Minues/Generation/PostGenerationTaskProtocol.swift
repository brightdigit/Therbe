// PostGenerationTaskProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

public protocol PostGenerationTaskProtocol {
  mutating func completion(_ completion: @escaping (Result<ContentEntryProtocol, Error>) -> Void)
  func resume()
}
