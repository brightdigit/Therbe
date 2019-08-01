// ContentEntryFactoryProtocol.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion on 7/31/19.

import Foundation

public protocol ContentEntryFactoryProtocol {
  associatedtype ContentEntryType : ContentEntryProtocol
  func saveContentEntry(fromMarkdown markdown: String, withDestinationDirectory destinationURL: URL) throws -> ContentEntryType
}
