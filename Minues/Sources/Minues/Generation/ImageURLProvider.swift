// ImageURLProvider.swift
// Copyright (c) 2019 BrightDigit
// Created by Leo Dion.

import Foundation

public protocol ImageURLProvider {
  func imageUrl(withSize size: Size) -> URL
}
