// PicsumPhotoURLProvider.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

public struct PicsumPhotoURLProvider: ImageURLProvider {
  static let photoURLTemplate = "https://picsum.photos/id/%d/%d/%d"
  public func imageUrl(withSize _: Size) -> URL {
    return URL(string: String(format: PicsumPhotoURLProvider.photoURLTemplate, Int.random(in: 1 ... 1000), 1920, 960))!
  }
}
