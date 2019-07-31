// PostGeneratorProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

public protocol PostGeneratorProtocol {
  func next() -> PostGenerationTaskProtocol
}
