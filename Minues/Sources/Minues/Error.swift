// Error.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

@available(*, deprecated, renamed: "MinuesError")
struct NoDocumentDirectoryError: Error {}
@available(*, deprecated, renamed: "MinuesError")
public struct NotImplementedError: Error {}
@available(*, deprecated, renamed: "MinuesError")
struct MissingTitleError: Error {}
@available(*, deprecated, renamed: "MinuesError")
struct NoDataError: Error {}

public enum MinuesError: Error {
  case invalidState
}
