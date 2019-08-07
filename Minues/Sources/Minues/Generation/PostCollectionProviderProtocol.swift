// PostCollectionProviderProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

public protocol PostCollectionProviderProtocol {
  func generate(_ count: Int, using generator: PostGeneratorProtocol) -> PostCollectionTaskProtocol
}
